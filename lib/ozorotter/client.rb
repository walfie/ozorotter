require 'ozorotter/image_data'

module Ozorotter
  class Client
    attr_accessor :image_searcher, :fallback_image_searcher, :weather_api, :image_composer

    # Usage:
    #
    # Ozorotter.new do |o|
    #   o.image_searcher = flickr
    #   o.fallback_image_searcher = google
    #   o.weather_api = weather_api
    #   o.image_composer = image_composer
    # end
    def initialize(logging_enabled: true)
      @logging_enabled = logging_enabled

      yield(self) if block_given?
    end

    def image_from_location(location_name, save_path=nil)
      weather = weather_api.get_weather(location_name)
      image_from_weather(weather, save_path)
    end

    def image_from_weather(weather, save_path=nil)
      photo = image_searcher.search(weather) || fallback_image_searcher.search(weather)
      raise 'Photo search failed' if photo.nil?

      overlay = image_composer.random_overlay(weather)
      image = image_composer.compose_image(weather, overlay, photo)

      image.write(save_path) unless save_path.nil?

      ImageData.new(
        image: image,
        image_path: save_path,
        photo: photo,
        weather: weather
      )
    end
  end
end

