# Oh boy let me tell you about how bad this code is
require 'dotenv'
Dotenv.load

require 'mini_magick'
require 'yaml'
require_relative 'ozorotter/weather'
require_relative 'ozorotter/weather_api'
require_relative 'ozorotter/search'
require_relative 'ozorotter/twitter'
require_relative 'mini_magick/image'

module Ozorotter
  # TODO: Better config management (not hardcoded filename)
  @config ||= YAML.load_file 'config.yml'

  module_function
  def image_from_weather weather
    time_of_day = weather.icon.include?('nt_') ? 'night' : 'day'
    location = weather.location
    category = weather.categorize

    # Search Google for an image
    background = Search::search "#{location} #{time_of_day}", category

    # Get random overlay image from local folder
    foreground = random_foreground category

    # Put it all together
    make_image weather, foreground, background
  end

  def random_foreground weather_type='default'
    img_dir = @config['image']['overlay_dir']
    sub_dir = Dir.exists?("#{img_dir}/#{weather_type}") ? weather_type : 'default'

    Dir["#{img_dir}/#{sub_dir}/*.{png,gif}"].sample
  end

  def make_image weather, overlay_path, background_url
    opts = @config['image']
    w, h = opts['width'], opts['height']
    font_size = opts['font_size']
    margin = opts['margin']

    degrees = weather.temperature_string
    time = weather.time_string

    background = MiniMagick::Image.open(background_url).resize_to_fill w, h
    overlay = MiniMagick::Image.open overlay_path
    icon = MiniMagick::Image.open weather.icon

    img = background.composite icon do |c|
      c.geometry "#{opts['icon_size']}x+#{2*margin}+#{2*margin}"
    end

    img = img.composite overlay do |c|
      c.gravity 'South'
    end

    img = img.combine_options do |c|
      c.font 'font/rounded-mplus-1c-bold.ttf'
      c.strokewidth opts['stroke_width']
      c.interline_spacing opts['interline_spacing']

      draw = ->(text, x, y, color='white') do
        draw_command = "text #{x},#{y} '#{text}'"

        # Outline
        c.stroke 'black'
        c.fill 'black'
        c.draw draw_command

        # Fill
        c.stroke 'none'
        c.fill color
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

