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

    private
    def get_api_url(location_id)
      "http://api.wunderground.com/api/#{@api_key}/conditions/q/#{location_id}.json"
    end

    def get_json(url)
      # TODO: Error handling
      uri = URI.parse(url)
      body = Net::HTTP.get(uri)
      JSON.parse(body)
    end

    # Parse the 'current_observation' field of the wunderground response JSON
    def parse_observation_hash(observation)
      time = Time
        .at(observation['local_epoch'].to_i || Time.now)
        .in_time_zone(observation['local_tz_long'])

      location = Ozorotter::Location.new(
        name: observation['display_location']['full'],
        lat: observation['display_location']['latitude'],
        long: observation['display_location']['longitude']
      )

      puts "Visiting #{location.name}..." if @logging_enabled

      temperature = Ozorotter::Temperature.new(observation['temp_c'])

      Ozorotter::Weather.new(
        temperature: temperature,
        description: observation['weather'],
        humidity: observation['relative_humidity'],
        icon: observation['icon_url'],
        location: location,
        time: time
      )
    end

  end
end

