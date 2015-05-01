require 'ozorotter/location'
require 'ozorotter/temperature'
require 'ozorotter/weather'
require 'ozorotter/errors'

require 'active_support/inflector/methods' # titleize
require 'json'
require 'open-uri'
require 'net/http'

module Ozorotter::Dal
  class YahooWeather
    def initialize(logging_enabled=true)
      @logging_enabled = logging_enabled
    end

    def get_weather(location)
      query = %Q{
        SELECT item.lat, item.long, item.condition, item.description, atmosphere, location
        FROM weather.forecast
        WHERE u="c"
        AND woeid in (
          SELECT woeid
          FROM geo.places(1)
          WHERE text="#{location}"
        )
      }

      get_weather_from_yql(query)
    end

    def get_weather_from_geo(lat, long)
      query = %Q{
        SELECT item.lat, item.long, item.condition, item.description, atmosphere, location
        FROM weather.forecast
        WHERE u="c"
        AND woeid in (
          SELECT woeid
          FROM geo.placefinder
          WHERE text="#{lat}, #{long}"
          AND gflags="R"
        )
      }

      get_weather_from_yql(query)
    end

    def get_weather_from_yql(yql)
      url = get_api_url(yql)
      json = get_json(url)
      parse_api_response(json)
    end

    private
    def get_api_url(yql)
      compact_yql = yql.gsub(/\s+/, ' ') # Compact whitespace
      "https://query.yahooapis.com/v1/public/yql?format=json&q=#{URI.escape(compact_yql)}"
    end

    def parse_api_response(json)
      base = json['query'].to_h['results'].to_h['channel']

      loc = base['location']
      item = base['item']

      region_and_country = [
        loc['region'].presence,
        loc['country'].presence
      ].compact.join(', ')

      location = Ozorotter::Location.new(
        name: "#{loc['city']}\n#{region_and_country}",
        lat: item['lat'].to_f,
        long: item['long'].to_f
      )

      puts "Yahoo: Visiting #{location.name}..." if @logging_enabled

      condition = item['condition']
      temperature = Ozorotter::Temperature.new(condition['temp'].to_f)

      icon = parse_icon_from_description(item['description'])
      # TODO: time_of_day?

      Ozorotter::Weather.new(
        temperature: temperature,
        description: condition['text'],
        humidity: "#{base['atmosphere']['humidity']}%",
        icon: icon,
        location: location,
        time: nil
      )
    end

    def parse_icon_from_description(desc)
      desc.match(/(http:.*\.gif)/)[1]
    end

    # This is copy/pasted exactly from OpenWeatherMap class.
    # TODO: Stop copy/pasting?
    def get_json(url)
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)

      body =
        case response.code.to_s
        when '404'
          raise Ozorotter::Errors::NotFoundError.new(url), '404 error'
        when '200'
          response.body
        else
          raise Ozorotter::Errors::ServerError.new(url), 'Server error'
        end

      JSON.parse(body)
    end
  end
end

