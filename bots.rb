$LOAD_PATH.unshift('lib')

require 'dotenv'
require 'ozorotter'
require 'twitter_ebooks'
require 'yaml'

Dotenv.load

config = YAML.load_file('config.yml')

google = Ozorotter::Dal::GoogleImages.new
weather_api = Ozorotter::Dal::OpenWeatherMap.new(ENV['OPENWEATHERMAP_KEY'])
geonames_weather = Ozorotter::Dal::GeonamesWeather.new(ENV['GEONAMES_KEY'], weather_api)

image_composer = Ozorotter::ImageComposer.new(config['image'])

ozorotter = Ozorotter::Client.new do |o|
  o.image_searcher = google
  o.fallback_image_searcher = google
  o.weather_api = geonames_weather
  o.image_composer = image_composer
end

keys = {
  consumer_key: ENV['TWITTER_CONSUMER_KEY'],
  consumer_secret: ENV['TWITTER_CONSUMER_SECRET']
}

Ozorotter::Bot::WeatherBot.new(ENV['BOT_USERNAME'], ozorotter, keys) do |bot|
  bot.access_token = ENV['TWITTER_ACCESS_TOKEN']
  bot.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

