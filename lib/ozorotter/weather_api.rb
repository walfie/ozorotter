require 'active_support/core_ext/time'
require 'json'
require 'net/http'
require 'uri'
require 'yaml'
require_relative 'weather'

# TODO: Probably should make this into a class that takes a key as input
module Ozorotter::WeatherAPI
  @key = ENV['WUNDERGROUND_KEY']

  @config ||= YAML.load_file('config.yml')['weather']
  @locations = YAML.load_file @config['locations_file']

  module_function

  def random_weather
    get_weather random_location
  end

  def random_location
    @locations.sample
  end

  def get_json url
    uri = URI.parse url
    body = Net::HTTP.get uri
    json = JSON.parse body
  end

  def get_weather location
    url = "http://api.wunderground.com/api/#{@key}/conditions/q/#{location}.json"
    json = get_json(url)['current_observation']

    # DEBUG
    puts url

    time = Time
      .at(json['local_epoch'].to_i || Time.now)
      .in_time_zone(json['local_tz_long'])

    Ozorotter::Weather.new(
      time: time,
      location: json['display_location']['full'],
      lat: json['display_location']['latitude'],
      long: json['display_location']['longitude'],
      description: json['weather'],
      celsius: json['temp_c'],
      humidity: json['relative_humidity'],
      icon: json['icon_url']
    )
  end
end

