$LOAD_PATH.unshift('lib')

require 'dotenv'
require 'ozorotter'
require 'twitter_ebooks'
require 'active_support/core_ext/numeric/time'
require 'active_support/cache'
require 'yaml'

Dotenv.load

config = YAML.load_file('config.yml')

flickr_keys = { api_key: ENV['FLICKR_KEY'], shared_secret: ENV['FLICKR_SECRET'] }
flickr = Ozorotter::Dal::Flickr.build(flickr_keys, config['flickr'])
google = Ozorotter::Dal::GoogleImages.new

# Use Yahoo weather, with OpenWeatherMap as a fallback
yahoo_weather = Ozorotter::Dal::YahooWeather.new
openweathermap = Ozorotter::Dal::OpenWeatherMap.new(ENV['OPENWEATHERMAP_KEY'])
multi_weather = Ozorotter::Dal::MultiWeather.new([yahoo_weather, openweathermap])

geonames_weather = Ozorotter::Dal::GeonamesWeather.new(ENV['GEONAMES_KEY'], multi_weather)

image_composer = Ozorotter::ImageComposer.new(config['image'])

ozorotter = Ozorotter::Client.new do |o|
  o.image_searcher = flickr
  o.fallback_image_searcher = google
  o.weather_api = geonames_weather
  o.image_composer = image_composer
end

keys = {
  consumer_key: ENV['TWITTER_CONSUMER_KEY'],
  consumer_secret: ENV['TWITTER_CONSUMER_SECRET']
}

# TODO: Don't hardcode the number of minutes
location_cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 10.minutes)
user_cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 20.minutes)

Ozorotter::Bot::WeatherBot.new(
  name: ENV['BOT_USERNAME'],
  ozorotter: ozorotter,
  keys: keys,
  location_cache: location_cache,
  user_cache: user_cache
) do |bot|
  bot.access_token = ENV['TWITTER_ACCESS_TOKEN']
  bot.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

