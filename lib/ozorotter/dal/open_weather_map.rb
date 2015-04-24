require 'ozorotter/location'
require 'ozorotter/temperature'
require 'ozorotter/weather'
require 'ozorotter/errors'

require 'active_support/inflector/methods' # titleize
require 'json'
require 'open-uri'
require 'net/http'

module Ozorotter::Dal
  class OpenWeatherMap
    def initialize(api_key, logging_enabled=true)
      @api_key = api_key
      @logging_enabled = logging_enabled
    end

    def get_weather(location_name, n_tries=5)
      url = get_api_url(location_name)
      json = get_json(url)

      puts url if @logging_enabled

      parse_api_response(json)
    rescue Ozorotter::Errors::ServerError
      puts "'#{location_name}' 500 error, #{n_tries} retries left" if @logging_enabled
      retry unless (n_tries -=1).zero?
    end

    # Parse the response hash of the OpenWeatherMap JSON
    def parse_api_response(json)
      if json['cod'] == '404'
        # The API doesn't properly respond with a 404 status, we have to check the JSON
        raise Ozorotter::Errors::NotFoundError.new, '404 error'
      end

      time = nil # TODO: Handle timezones?

      coord = json['coord']
      location = Ozorotter::Location.new(
        name: "#{json['name']}, #{json['sys']['country']}",
        lat: coord['lat'],
        long: coord['lon']
      )

      puts "Visiting #{location.name}..." if @logging_enabled

      temperature = Ozorotter::Temperature.new(json['main']['temp'])

      weather_json = json['weather'].first # TODO: Handle failure
      icon = icon_url(weather_json['icon'])
      time_of_day = weather_json['icon'].include?('n') ? 'night' : 'day'

      Ozorotter::Weather.new(
        temperature: temperature,
        description: weather_description(weather_json['description']),
        humidity: "#{json['main']['humidity']}%",
        icon: icon,
        location: location,
        time: time,
        time_of_day: time_of_day
      )
    end

    private
    # Titlecase weather description and various other filtering
    def weather_description(description)
      # Add other sanitization things here if necessary
      # This one gets rid of "Sky Is Clear" which looks kinda weird
      description.downcase.gsub('sky is ', '').titleize
    end

    def get_api_url(location)
      escaped_location = URI.escape(location)
      "http://api.openweathermap.org/data/2.5/weather?APPID=#{@api_key}&units=metric&q=#{escaped_location}"
    end

    def icon_url(filename)
      "http://openweathermap.org/img/w/#{filename}.png"
    end

    def get_json(url)
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)

      body =
        case response.code.to_s
        when '404' # Actually, the API currently returns a 200 when not found...
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

