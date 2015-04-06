# Oh boy let me tell you about how bad this code is

require 'mini_magick'
require 'yaml'
require_relative 'ozorotter/weather'
require_relative 'ozorotter/weather_api'
require_relative 'ozorotter/search'
require_relative 'mini_magick/image'

module Ozorotter
  # TODO: Better config management (not hardcoded filename)
  @config ||= YAML.load_file 'config.yml'

  module_function
  def random_image
    weather = WeatherAPI::random_weather
    time_of_day = weather.icon.include?('nt_') ? 'night' : 'day'
    location = weather.location.split(',').first

    background = Search::search "#{location} #{time_of_day}", weather.description
    foreground = random_foreground
    make_image weather, foreground, background
  end

  def random_foreground
    # TODO: Account for weather type
    img_dir = @config['image']['overlay_dir']
    Dir["#{img_dir}/*.{png,gif}"].sample
  end

  def make_image weather, overlay_path, background_url
    opts = @config['image']
    w, h = opts['width'], opts['height']
    font_size = opts['font_size']
    margin = opts['margin']

    degrees = "#{weather.celsius.round 1}°C | #{weather.fahrenheit.round 1}°F"
    time = weather.time.strftime "%a %-I:%M%p (%Z)\n%Y/%m/%d"

    background = MiniMagick::Image.open(background_url).resize_to_fill w, h
    overlay = MiniMagick::Image.open overlay_path
    icon = MiniMagick::Image.open weather.icon

    img = background.composite icon do |c|
      c.geometry "#{opts['icon_size']}x+#{2*margin}+#{2*margin}"
    end

    img = img.composite(overlay).combine_options do |c|
      c.font 'font/rounded-mplus-1c-bold.ttf'
      c.strokewidth opts['stroke_width']
      c.interline_spacing opts['interline_spacing']

      draw = ->(text, x, y) do
        draw_command = "text #{x},#{y} '#{text}'"

        # Outline
        c.stroke 'black'
        c.fill 'black'
        c.draw draw_command

        # Fill
        c.stroke 'none'
        c.fill 'white'
        c.draw draw_command
      end

      c.gravity 'SouthWest'
      # Location
      c.pointsize font_size
      draw.call weather.location, margin, 0

      # Time
      c.pointsize 0.5*font_size
      draw.call time, margin, 1.2*font_size

      c.gravity 'NorthEast'
      # Temperature
      c.pointsize font_size
      draw.call degrees, margin, 0

      c.pointsize 0.75*font_size

      # Humidity
      draw.call "Humidity: #{weather.humidity}", margin, 1.2*font_size

      # Description
      draw.call weather.description, margin, 2.1*font_size
    end

    img
  end
end

