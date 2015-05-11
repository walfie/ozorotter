require 'mini_magick'

require 'active_support/core_ext/hash/keys'

module Ozorotter
  class ImageComposer
    # See the `image` object in `config.yml` for options
    def initialize(config)
      @config = config.symbolize_keys
    end

    # Get path to a random overlay based on the weather
    def random_overlay(weather)
      img_dir = @config[:overlay_dir]
      sub_dir =
        if weather.category =~ /rain|storm/
          'rainy'
        elsif weather.time && weather.time.hour < 6
          '{sleepy,default}'
        else
          'default'
        end

      Dir["#{img_dir}/#{sub_dir}/*.{png,gif}"].sample
    end

    # Combine photo with Akari overlay and text related to the weather
    def compose_image(weather, overlay_path, photo)
      w, h = @config[:width], @config[:height]
      font_size = @config[:font_size]
      margin = @config[:margin]

      degrees = weather.temperature.to_s

      background = resize_to_fill(MiniMagick::Image.open(photo.image_url), w, h)
      overlay = MiniMagick::Image.open(overlay_path)

      img = background.composite overlay do |c|
        c.gravity 'South'
      end

      begin
        icon = MiniMagick::Image.open(weather.icon)
        img = img.composite icon do |c|
          c.geometry "#{@config[:icon_size]}x+#{2*margin}+#{2*margin}"
        end
      rescue
        # If icon fails to load, don't overlay it
      end

      img = img.combine_options do |c|
        c.font @config[:font]
        c.strokewidth @config[:stroke_width]
        c.interline_spacing @config[:interline_spacing]

        draw = ->(text, x, y, color='white') do
          draw_command = "text #{x},#{y} '#{text.gsub("'"){"\\'"}}'"

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

        # Add source, if available
        location_offset = 0
        if photo.author && photo.short_url
          c.pointsize 0.4*font_size
          draw.call "Photo by #{photo.author} #{photo.short_url}", margin, margin
          location_offset = 0.5*font_size
        end

        # Location. Render the first line in standard size, other lines smaller
        location_lines = weather.location.name.split("\n")
        main_location = location_lines.shift

        if location_offset != 0 && !location_lines.empty?
          location_offset += 0.1*font_size
        end

        c.pointsize 0.6*font_size
        location_lines.each do |l|
          draw.call l, margin, location_offset
          location_offset += 0.6*font_size
        end

        c.pointsize font_size
        draw.call main_location, margin, location_offset

        # Time
        c.pointsize 0.5*font_size
        draw.call weather.time_string, margin, (1.2*font_size + location_offset)

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

    private
    # Copied from CarrierWave
    def resize_to_fill(image, width, height, gravity='Center')
      cols, rows = image[:dimensions]
      image.combine_options do |cmd|
        if width != cols || height != rows
          scale_x = width/cols.to_f
          scale_y = height/rows.to_f
          if scale_x >= scale_y
            cols = (scale_x * (cols + 0.5)).round
            rows = (scale_x * (rows + 0.5)).round
            cmd.resize "#{cols}"
          else
            cols = (scale_y * (cols + 0.5)).round
            rows = (scale_y * (rows + 0.5)).round
            cmd.resize "x#{rows}"
          end
        end

        cmd.gravity gravity
        cmd.background "rgba(255,255,255,0.0)"
        cmd.extent "#{width}x#{height}" if cols != width || rows != height
      end
    end
  end
end

