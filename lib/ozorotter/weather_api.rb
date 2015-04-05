require 'json'
require 'net/http'
require 'uri'
require_relative 'weather'

module Ozorotter::WeatherAPI
  @config ||= YAML.load_file('config.yml')['weather']
  # TODO: Better config management (not hardcoded filename)
  @key = @config['api']['key']
  @locations_file = @config['locations_file']

  module_function

  def random_weather
    get_weather random_location
  end

  def random_location
    location = File.readlines(@locations_file)
      .reject(&:blank?)
      .sample.sub("\n", '')
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
      .in_time_zone json['local_tz_long']

    location = json['display_location']['full']
    description = json['weather']
    celsius = json['temp_c']
    icon = json['icon_url']

    Ozorotter::Weather.new time, location, description, celsius, icon
  end
end

