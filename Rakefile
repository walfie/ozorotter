require_relative 'lib/ozorotter'
require 'active_support/core_ext/time'

task :tweet do
  weather = Ozorotter::WeatherAPI::random_weather
  text = [
    weather.location,
    "#{weather.temperature_string}",
    "Humidity: #{weather.humidity}",
    weather.description
  ].join("\n")

  # Is there some way to convert an image to a file without saving and opening it?
  out_path = 'output/out.jpg'
  image = Ozorotter::image_from_weather weather
  image.write out_path

  file = open out_path
  Ozorotter::Twitter.tweet text, file
end

task :test do
  out_path = 'output/test.jpg'

  weather = Ozorotter::Weather.new(
    Time.now,
    'New York City, NY',
    'Partly Cloudy',
    10.0,
    '50%',
    'http://icons-ak.wxug.com/i/c/k/partlycloudy.gif'
  )
  image = Ozorotter::image_from_weather weather
  image.write out_path
end

