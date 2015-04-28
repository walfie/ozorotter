require 'ozorotter/dal/geonames'

module Ozorotter::Dal
  class GeonamesWeather < Ozorotter::Dal::Geonames
    def initialize(api_key, weather_api)
      @weather_api = weather_api
      super(api_key)
    end

    def get_weather(location_name)
      loc = get_location(location_name)

      return nil if loc.nil?

      puts "Geonames: #{location_name} -> #{loc.name}" # TODO: Check if logging enabled

      weather = @weather_api.get_weather_from_geo(loc.lat, loc.long)
      weather.location = loc

      if weather.time.nil?
        timezone = get_timezone(loc.lat, loc.long)
        weather.time = Time.now.in_time_zone(timezone) if timezone
      end

      weather
    rescue Ozorotter::Errors::ServerError # Probably rate limited
      @weather_api.get_weather(location_name)
    end

    def get_weather_from_geo(*args)
      # TODO: Should still get location and timezone info
      @weather_api.get_weather_from_geo(*args)
    end
  end
end

