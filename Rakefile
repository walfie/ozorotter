require_relative 'lib/ozorotter'
require 'active_support/core_ext/time'

task :test do
  weather = Ozorotter::WeatherAPI.get_weather 'NY/New_York_City'

  img = Ozorotter::make_image \
    weather,
    'tmp/test.png',
    'tmp/snow.jpg'
  img.write 'out.jpg'
end

