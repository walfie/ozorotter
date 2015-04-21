require 'active_support/inflector/methods' # titleize
require 'json'
require 'net/http'
require 'uri'

module Ozorotter::Dal
  class OpenWeatherMap
    def initialize(api_key, logging_enabled=true)
      @api_key = api_key
      @logging_enabled = logging_enabled
    end

    def get_weather(search)
      url = get_api_url(search)
      json = get_json(url)

      puts url if @logging_enabled

      parse_api_response(json)
    end

    # Parse the response hash of the OpenWeatherMap JSON
    def parse_api_response(json)
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
        description: weather_json['description'].titleize,
        humidity: "#{json['main']['humidity']}%",
        icon: icon,
        location: location,
        time: time,
        time_of_day: time_of_day
      )
    end

    private
    def get_api_url(location)
      "http://api.openweathermap.org/data/2.5/find?APPID=#{@api_key}&units=metric&q=#{location}"
    end

    def icon_url(filename)
      "http://openweathermap.org/img/w/#{filename}.png"
    end

    def get_json(url)
      # TODO: Error handling
      uri = URI.parse(url)
      body = Net::HTTP.get(uri)
      JSON.parse(body)
    end

  end
end

