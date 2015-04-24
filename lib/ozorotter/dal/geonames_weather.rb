require 'ozorotter/dal/geonames'

module Ozorotter::Dal
  class GeonamesWeather < Ozorotter::Dal::Geonames
    def initialize(api_key, weather_api)
      @weather_api = weather_api
      super(api_key)
    end

    def get_weather(location_name)
      loc = get_location(location_name)

      puts "Geonames: #{location_name} -> #{loc.name}" # TODO: Check if logging enabled

      weather = @weather_api.get_weather_from_geo(loc.lat, loc.long)
      weather.location = loc
      weather
    rescue Ozorotter::Errors::ServerError # Probably rate limited
      @weather_api.get_weather(location_name)
    end
  end
end
