require_relative 'ozorotter'
require 'active_support/core_ext/time'

task :test do
  weather = Ozorotter::Weather.new \
    Time.at(1428178505).in_time_zone('Asia/Tokyo'),
    'Tokyo, Japan',
    'Light Rain',
    10

  Ozorotter::make_image \
    weather,
    'tmp/test.png',
    'tmp/snow.jpg',
    'tmp/nt_rain.gif'
end

