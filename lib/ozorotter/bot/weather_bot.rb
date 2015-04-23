require 'ozorotter'

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

    def on_mention(tweet)
      location = tweet.text
        .gsub(/@\w*/, '') # Strip @'s
        .match(/weather (.*)/).to_a[1]

      return unless location

      image_data = get_image_data(location)
      if image_data.nil?
        reply(tweet, meta(tweet).reply_prefix + "Sorry, I don't know this place!")
        return
      end

      reply_with_image(tweet, image_data)
    end

    def get_image_data(location, tries=5)
      @ozorotter.image_from_location(location, 'output/test.jpg')
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
      pictweet(text, image_data.image_path, opts)
    end
  end
end

