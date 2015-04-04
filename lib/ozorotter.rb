# Oh boy let me tell you about how bad this code is

require 'mini_magick'
require 'yaml'
require_relative 'ozorotter/weather'
require_relative 'mini_magick/image'

module Ozorotter
  @config ||= YAML.load_file 'config.yml'

  module_function

  def make_image weather, overlay_path, background_url, icon_url
    opts = @config['image']
    w, h = opts['width'], opts['height']
    font_size = opts['font_size']
    margin = opts['margin']

    degrees = "#{weather.celsius.round 1}°C | #{weather.fahrenheit.round 1}°F"
    time = weather.time.strftime "%a %-I:%m%p (%Z)\n%Y/%m/%d"

    background = MiniMagick::Image.open(background_url).resize_to_fill w, h
    overlay = MiniMagick::Image.open overlay_path
    icon = MiniMagick::Image.open icon_url

    img = background.composite(overlay).combine_options do |c|
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

      c.pointsize font_size
      c.gravity 'SouthWest'
      draw.call weather.location, margin, 0
      c.pointsize 0.5*font_size
      draw.call time, margin, 1.2*font_size

      c.pointsize font_size
      c.gravity 'NorthEast'
      draw.call degrees, margin, 0
      c.pointsize 0.75*font_size
      draw.call weather.description, margin, 1.2*font_size
    end

    img = img.composite icon do |c|
      c.geometry "#{opts['icon_size']}x+#{2*margin}+#{2*margin}"
    end

    img
  end
end

