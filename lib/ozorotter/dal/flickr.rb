require 'ozorotter/photo'
require 'ozorotter/weather'

require 'active_support/core_ext/hash/keys'
require 'flickraw'

module Ozorotter::Dal
  class Flickr

    # Initialize object with API keys.
    #
    # See `#initialize` for possible config values
    def self.build(keys={}, config={}, logging_enabled=true)
      FlickRaw.api_key = keys[:api_key]
      FlickRaw.shared_secret = keys[:shared_secret]
      flickr = FlickRaw::Flickr.new

      Flickr.new(flickr, config, logging_enabled)
    end

    # Initialize with flickr object (see `#build` to initialize with keys)
    #
    # Config object can contain the following keys:
    #   :accuracy, :radius, :licenses, :group_id (Flickr API)
    #   :photos_threshold (Minimum number of photos, else search returns nil)
    #
    # See Flickr's API documentation for valid values.
    # https://www.flickr.com/services/api/flickr.photos.search.html
    def initialize(flickr, config={}, logging_enabled=true)
      @flickr = flickr
      @config = config.symbolize_keys
      @photos_threshold = @config[:photos_threshold] || 10
      @logging_enabled = logging_enabled
    end

    def search(weather)
      params = params_from_weather(weather)

      # Keep trying until one of the API calls returns enough photos
      photos =
        search_with_tags(weather, params) ||
        search_without_group_id!(params) ||
        search_without_tags!(weather, params)

      return nil if photos.nil?

      flickr_photo = photos.sample
      photo = Ozorotter::Photo.from_flickr_photo(flickr_photo)

      puts %Q{"#{photo.title}" by #{photo.author}\n#{photo.page_url}} if @logging_enabled

      photo
    end


    private
    def params_from_weather(weather)
      {
        lat: weather.location.lat.to_s,
        lon: weather.location.long.to_s,
        tags: weather.category,
        tag_mode: 'all',
        extras: 'owner_name,tags',
        safe_search: 1,
        accuracy: @config[:accuracy],
        radius: @config[:radius],
        license: @config[:licenses],
        group_id: @config[:group_id],
      }
    end

    def search_with_params(params)
      @flickr.photos.search(params).to_a
    end

    #
    # Convenience methods for retrying if not enough photos returned
    # Note that they modify the params hash that is passed in.
    #
    def length_check(photos)
      photos.length < @photos_threshold ? nil : photos
    end

    def search_with_tags(weather, params)
      photos = search_with_params(params)

      filtered_photos = photos.select { |p| p.tags.include?(weather.time_of_day) }

      if @logging_enabled
        searched = "#{params[:tags]},#{weather.time_of_day}"
        puts "Searching Flickr: #{searched} (#{filtered_photos.length})"
      end
      return filtered_photos if length_check(filtered_photos)

      puts "Without day/night (#{photos.length})" if @logging_enabled

      length_check(photos)
    end

    def search_without_group_id!(params)
      params.delete(:group_id)
      photos = search_with_params(params)
      puts "Searching without group ID (#{photos.length})" if @logging_enabled

      length_check(photos)
    end

    def search_without_tags!(weather, params)
      params.delete(:tags)
      params.delete(:lat)
      params.delete(:long)

      params[:text] = "#{weather.location.name} #{weather.category} #{weather.time_of_day}"
      photos = search_with_params(params)
      puts "Searching text: #{params[:text]} (#{photos.length})" if @logging_enabled

      length_check(photos)
    end
  end
end

