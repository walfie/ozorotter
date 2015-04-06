require 'twitter'
require 'open-uri'
require 'yaml'

module Ozorotter::Twitter
  # TODO: Consider load order of .env ?

  module_function

  def client
    return @client if @client

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end

  def tweet text, file
    tweet = begin
      client.update_with_media text, file
    rescue Twitter::Error::RequestTimeout
      sleep 15
      retry
    end
  end
end
