require 'json'
require 'net/http'
require 'uri'
require_relative 'weather'

module Ozorotter::WeatherAPI
  # TODO: Better config management (not hardcoded filename)
  @key ||= YAML.load_file('config.yml')['weather_underground']['api']['key']

  module_function

  def get_json url
    uri = URI.parse url
    body = Net::HTTP.get uri
    json = JSON.parse body
  end

  def get_weather location
    #url = "http://api.wunderground.com/api/#{@key}/conditions/q/#{location}.json"
    url = 'http://localhost:8000/tmp/sample.json'
    json = get_json(url)['current_observation']

    time = Time.at(json['local_epoch'].to_i).in_time_zone json['local_tz_long']
    location = json['display_location']['full']
    description = json['weather']
    celsius = json['temp_c']
    icon = json['icon_url']

    Ozorotter::Weather.new time, location, description, celsius, icon
  end
end

