require 'ozorotter/location'
require 'ozorotter/temperature'
require 'ozorotter/weather'

require 'active_support/core_ext/time'
require 'json'
require 'net/http'
require 'uri'

module Ozorotter::Dal
  class Wunderground
    def initialize(api_key, logging_enabled=true)
      @api_key = api_key
      @logging_enabled = logging_enabled
    end

    def get_weather(location_id)
      url = get_api_url(location_id)
      json = get_json(url)

      puts url if @logging_enabled

      parse_observation_hash(json['current_observation'])
    end

    def get_weather_from_geo(lat, long)
      get_weather("#{lat},#{long}")
    end

    # Parse the 'current_observation' field of the wunderground response JSON
    def parse_observation_hash(observation)
      time = Time
        .at(observation['local_epoch'].to_i || Time.now)
        .in_time_zone(observation['local_tz_long'])

      display_location = observation['display_location'] || {}
      location = Ozorotter::Location.new(
        name: display_location['full'],
        lat: display_location['latitude'],
        long: display_location['longitude']
      )

      puts "Wunderground: Visiting #{location.name}..." if @logging_enabled

      temperature = Ozorotter::Temperature.new(observation['temp_c'])

      icon = observation['icon_url']
      time_of_day = icon.include?('nt_') ? 'night' : 'day'

      Ozorotter::Weather.new(
        temperature: temperature,
        description: observation['weather'],
        humidity: observation['relative_humidity'],
        icon: icon,
        location: location,
        time: time,
        time_of_day: time_of_day
      )
    end

    private
    def get_api_url(query)
      "http://api.wunderground.com/api/#{@api_key}/conditions/q/#{URI.escape(query)}.json"
    end

    def get_json(url)
      # TODO: Error handling
      uri = URI.parse(url)
      body = Net::HTTP.get(uri)
      JSON.parse(body)
    end

  end
end

