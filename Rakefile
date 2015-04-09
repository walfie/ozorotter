require_relative 'lib/ozorotter'
require 'active_support/core_ext/time'

task :tweet do
  out_path = 'output/out.jpg'

  begin # Retry until we get an image
    weather = Ozorotter::WeatherAPI::random_weather
    text = [
      weather.location,
      "#{weather.temperature_string}",
      "Humidity: #{weather.humidity}",
      weather.description
    ].join("\n")

    # Is there some way to convert an image to a file without saving and opening it?
    image_data = Ozorotter::image_from_weather weather
  end until image_data
  image = image_data[:image]
  image.write out_path

  file = open out_path
  geo = { lat: weather.lat.to_f, long: weather.long.to_f }
  tweet = Ozorotter::Twitter.tweet text, file, geo

  meta = image_data[:meta]
  credits = if meta[:source] == 'flickr'
    %Q{Source: "#{meta[:title]}" by #{meta[:author]} on Flickr\n#{meta[:page_url]}}
  else
    "Source: #{meta[:image_url]} via #{meta[:page_url]}"
  end
  sleep rand(5..10)
  Ozorotter::Twitter.reply tweet, "@#{tweet.user.screen_name} #{credits}", geo
end

task :test do
  out_path = 'output/test.jpg'

  weather = Ozorotter::Weather.new(
    time: Time.now,
    location: 'New York City, NY',
    lat: '40.743301',
    long: '-73.985466',
    description: 'cloudy',
    celsius: 10.0,
    humidity: '50%',
    icon: 'http://icons-ak.wxug.com/i/c/k/nt_partlycloudy.gif'
  )
  image_data = Ozorotter::image_from_weather weather
  image_data[:image].write out_path
end

