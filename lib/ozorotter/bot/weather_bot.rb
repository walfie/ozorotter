require 'ozorotter/client'
require 'ozorotter/errors'

require 'active_support/cache'
require 'twitter_ebooks'

# This whole file is a mess
module Ozorotter::Bot
  class WeatherBot < Ebooks::Bot
    def initialize(
      name: '',
      ozorotter: nil,
      keys: {},
      user_cache: nil,
      location_cache: nil,
      &block
    )
      @ozorotter = ozorotter
      @user_cache = user_cache || ActiveSupport::Cache::NullStore.new
      @location_cache = location_cache || ActiveSupport::Cache::NullStore.new

      self.consumer_key = keys[:consumer_key]
      self.consumer_secret = keys[:consumer_secret]

      super(name, &block)
    end

    def configure
      self.delay_range = 1..3
    end

    def self.parse_weather(full_text)
      text = remove_ats(full_text)

      location =
        text.match(/(.+)のお?天気/).to_a[1] ||
        text.match(/weather (?:for|in|at|like )*([^?!.]+)/).to_a[1] ||
        text.match(/(.+) weather/).to_a[1]

      location = location.to_s.strip

      location == '' ? nil : location
    end

    def parse_weather(*args)
      self.class.parse_weather(*args)
    end

    # Allow n requests per user (until the cache entry expires)
    def user_limited?(key)
      @user_cache.read(key).to_i > 3 # TODO: Don't hardcode
    end

    # TODO: This method does too many things. Refactor it!
    def on_mention(tweet)
      if user_limited?(tweet.user.id) # To prevent spam
        puts "Ignoring tweet from @#{tweet.user.screen_name}"
        return
      end

      location = parse_weather(tweet.text)

      return unless location

      existing_tweet_text = @location_cache.read(location)
      return reply_with_text(tweet, existing_tweet_text) if existing_tweet_text

      save_path = "output/#{tweet.id}.jpg" # TODO: make this configurable

      image_data = get_image_data(location, save_path)
      if image_data.nil?
        reply_with_text(tweet, "Sorry, I don't know this place!")
        return
      end

      new_tweet = reply_with_image(tweet, image_data)
      @location_cache.write(location, remove_ats(new_tweet.text))

      File.delete(save_path) if File.exist?(save_path)

      @user_cache.increment(tweet.user.id)
    end

    def get_image_data(location, save_path='output/tweet.jpg', tries=5)
      @ozorotter.image_from_location(location, save_path)
    rescue Ozorotter::Errors::ServerError
      retry if (tries -=1) >= 0
    rescue Ozorotter::Errors::NotFoundError
      nil
    end

    def reply_with_text(tweet, text)
      response = meta(tweet).reply_prefix + text
      tweet(response, in_reply_to_status_id: tweet.id)
    end

    def reply_with_image(tweet, image_data)
      weather = image_data.weather
      text = meta(tweet).reply_prefix + weather.to_s

      opts = {
        in_reply_to_status_id: tweet.id,
        lat: weather.location.lat,
        long: weather.location.long
      }
      pic_tweet = pictweet(text, image_data.image_path, opts)

      # Reply with source
      # Commented out for now. 2400 tweets are allowed per day, and
      # replying with source would half that number...
      # TODO: Maybe have it handled by a separate account
      #text = "@#{tweet.user.screen_name} #{image_data.photo.credits}"
      #tweet(text, in_reply_to_status_id: pic_tweet.id)

      pic_tweet
    end

    def remove_ats(text)
      text.gsub(/@\w+/, '').strip
    end
  end
end

