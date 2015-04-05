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

    # TODO: This is for debugging only
    weather.location = WeatherAPI.random_location.split('/').last.gsub('_', ' ')
    weather.description = %w{
      storm rain cloudy sunny fog snow
    }.sample

    background = Search::search weather.location, weather.description
    foreground = random_foreground
    make_image weather, foreground, background
  end

  def random_foreground
    'tmp/test.png' # TODO: Change this
  end

  def make_image weather, overlay_path, background_url
    opts = @config['image']
    w, h = opts['width'], opts['height']
    font_size = opts['font_size']
    margin = opts['margin']

    degrees = "#{weather.celsius.round 1}°C | #{weather.fahrenheit.round 1}°F"
    time = weather.time.strftime "%a %-I:%m%p (%Z)\n%Y/%m/%d"

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

      # Description
      c.pointsize 0.75*font_size
      draw.call weather.description, margin, 1.2*font_size
    end

    img
  end
end

