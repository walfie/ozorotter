require 'ozorotter/client'
require 'ozorotter/errors'

require 'twitter_ebooks'

module Ozorotter::Bot
  class WeatherBot < Ebooks::Bot
    def initialize(name, ozorotter_client, keys={}, &block)
      @ozorotter = ozorotter_client
      self.consumer_key = keys[:consumer_key]
      self.consumer_secret = keys[:consumer_secret]

      super(name, &block)
    end

    def configure
      self.delay_range = 1..3
    end

    def self.parse_weather(full_text)
      text = full_text.gsub(/@\w+/, '') # remove @'s

      location =
        text.match(/(.+)のお?天気/).to_a[1] ||
        text.match(/weather (?:for|in|at|like )*([^?!.]+)/).to_a[1]

      location = location.to_s.strip

      location == '' ? nil : location
    end

    def parse_weather(*args)
      self.class.parse_weather(*args)
    end

    def on_mention(tweet)
      location = parse_weather(tweet.text)

      return unless location

      save_path = "output/#{tweet.id}.jpg" # TODO: make this configurable

      image_data = get_image_data(location, save_path)
      if image_data.nil?
        reply(tweet, meta(tweet).reply_prefix + "Sorry, I don't know this place!")
        return
      end

      reply_with_image(tweet, image_data)

      File.delete(save_path) if File.exist?(save_path)
    end

    def get_image_data(location, save_path='output/tweet.jpg', tries=5)
      @ozorotter.image_from_location(location, save_path)
    rescue Ozorotter::Errors::ServerError
      retry if (tries -=1) >= 0
    rescue Ozorotter::Errors::NotFoundError
      nil
    end

    def reply_with_image(tweet, image_data)
      weather = image_data.weather
      text = meta(tweet).reply_prefix + weather.to_s

      opts = {
        in_reply_to_status_id: tweet.id,
        lat: weather.location.lat,
        long: weather.location.long
      }
      t = pictweet(text, image_data.image_path, opts)

      text = "@#{t.user.screen_name} #{image_data.photo.credits}"
      reply(t, text)

      t
    end
  end
end

