require 'twitter'
require 'open-uri'

module Ozorotter::Dal
  class Twitter
    # Initialize with a `Twitter::REST::Client` object
    def initialize(client, logging_enabled=true)
      @client = client
      @logging_enabled = logging_enabled
    end

    def tweet_image(image_data)
      text = text_from_weather(image_data.weather)
      file = open(image_data.image_path)
      geo = geo_from_location(image_data.weather.location)

      t = tweet(text, file, geo)
      puts "Tweeted #{t.uri}\n" if @logging_enabled

      t
    end

    def tweet_source(original_tweet, image_data)
      photo = image_data.photo
      credits = if photo.source == 'flickr'
        source = %Q{Source: "#{photo.title}" by #{photo.author} on Flickr}

        # Assume '@username' plus the t.co URL take up 40 characters max
        if source.length > 100
          source = %Q{Source: Photo by #{photo.author} on Flickr}
        end
        source += "\n#{photo.page_url}"
        source.gsub('@', ' ')
      else
        "Source: #{photo.image_url} via #{photo.page_url}"
      end
      text = "@#{original_tweet.user.screen_name} #{credits}"

      geo = geo_from_location(image_data.weather.location)

      reply(original_tweet.id, text, geo)
    end

    private
    def tweet(text, file, options={})
      begin
        @client.update_with_media(text, file, options)
      rescue Twitter::Error::RequestTimeout
        sleep 15
        retry
      end
    end

    def reply(tweet_id, text, options={})
      @client.update(text, options.merge(in_reply_to_status_id: tweet_id))
    end

    def geo_from_location(location)
      {
        lat: location.lat.to_f,
        long: location.long.to_f
      }
    end

    def text_from_weather weather
      [
        weather.location.name,
        "#{weather.temperature.to_s}",
        "Humidity: #{weather.humidity}",
        weather.description
      ].join("\n")
    end
  end
end

