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
  puts "Tweeted: #{tweet.uri}\n"

  meta = image_data[:meta]
  credits =
    if meta.source == 'flickr'
      %Q{Source: "#{meta.title}" by #{meta.author} on Flickr\n#{meta.page_url}}
    else
      "Source: #{meta.image_url} via #{meta.page_url}"
    end
  sleep rand(5..10)
  Ozorotter::Twitter.reply tweet, "@#{tweet.user.screen_name} #{credits}", geo

  puts
end

task :map do
  tweets = Ozorotter::Twitter.client.user_timeline 'akari_oozora', count: 200, exclude_replies: true

  get_freqs = ->(data) do
    data
      .group_by { |x| x }
      .map { |k,v| { value: k, frequency: v.length } }
      .sort_by { |x| -x[:frequency] }
  end

  locations = tweets.map { |t| t.text.split("\n").first unless t.geo.nil? }.compact
  location_data = get_freqs
    .call(locations)
    .map { |x| "#{x[:value]} (#{x[:frequency]})" }
  puts location_data

  coordinates = tweets.map { |t| t.geo.coordinates.join(',') unless t.geo.nil? }.compact
  coordinates_data = get_freqs
    .call(coordinates)
    .map { |x| "markers=#{x[:value]}" }
    .take(25)
  coord_params = coordinates_data.join('&')
  puts "https://maps.googleapis.com/maps/api/staticmap?size=640x640&#{coord_params}"
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

