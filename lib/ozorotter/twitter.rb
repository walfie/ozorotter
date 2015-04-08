require 'twitter'
require 'open-uri'
require 'yaml'

module Ozorotter::Twitter
  # TODO: Consider load order of .env ?

  module_function

  # The main bot that posts the weather
  def client
    return @client if @client

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end

  # The bot that sources the tweets
  def client2
    return @client2 if @client2

    @client2 = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN2']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET2']
    end
  end

  def tweet text, file, options={}
    tweet = begin
      client.update_with_media text, file, options
    rescue Twitter::Error::RequestTimeout
      sleep 15
      retry
    end
  end

  def reply tweet_id, text, options={}
    client2.update text, options.merge(in_reply_to_status_id: tweet_id)
  end
end

