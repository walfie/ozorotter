require_relative 'lib/ozorotter'
require 'active_support/core_ext/time'

task :tweet, [:location] do |task, args|
  out_path = 'output/out.jpg'

  attempts_remaining = 5
  begin # Retry until we get an image
    location = args[:location] || Ozorotter::WeatherAPI::random_location
    weather = Ozorotter::WeatherAPI::get_weather location
    text = [
      weather.location,
      "#{weather.temperature_string}",
      "Humidity: #{weather.humidity}",
      weather.description
    ].join("\n")

    # Is there some way to convert an image to a file without saving and opening it?
    image_data = Ozorotter::image_from_weather weather
    attempts_remaining -= 1
  end until image_data || attempts_remaining.zero?
  image = image_data[:image]
  image.write out_path

  file = open out_path
  geo = { lat: weather.lat.to_f, long: weather.long.to_f }
  tweet = Ozorotter::Twitter.tweet text, file, geo
  puts "Tweeted: #{tweet.uri}\n"

  meta = image_data[:meta]
  credits =
    if meta.source == 'flickr'
      source = %Q{Source: "#{meta.title}" by #{meta.author} on Flickr}

      # Assume '@akari_oozora' plus the t.co URL take up 40 characters max
      if source.length > 100
        source = %Q{Source: Photo by #{meta.author} on Flickr}
      end
      source += "\n#{meta.page_url}"
      source.gsub('@', ' ')
    else
      "Source: #{meta.image_url} via #{meta.page_url}"
    end
  sleep rand(1..5)
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

  coordinates = tweets.map do |t|
    t.geo.coordinates.map{|x| x.round}.join(',') unless t.geo.nil?
  end.compact

  coordinates_data = get_freqs
    .call(coordinates)
    .map { |x| "markers=size:small|#{x[:value]}" }
  coord_params = coordinates_data.join('&')
  puts "https://maps.googleapis.com/maps/api/staticmap?size=550x400&center=35,0&#{coord_params}"
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

