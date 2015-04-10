require 'google-search'
require 'flickraw'
require_relative 'photo_data'

module Ozorotter::Search
  module_function

  FlickRaw.api_key = ENV['FLICKR_KEY']
  FlickRaw.shared_secret = ENV['FLICKR_SECRET']

  # TODO: Better config management
  @config ||= YAML.load_file('config.yml')['flickr']
  @photos_threshold = @config['photos_threshold']

  def google_search_map search_term
    mappings = {
      'rain' => 'rainy',
      'snow' => 'snow OR snowy',
      'storm' => 'storm -snow',
      'clear' => 'clear sky',
      'fog' => 'fog OR foggy'
    }
    mappings[search_term] || search_term
  end

  def google_search weather, n_tries=5
    query = "#{weather.location} #{google_search_map weather.category} #{weather.time_of_day}"
    puts "Searching Google: '#{query}'"

    n_tries.times do
      begin
        search_settings = {
          query: query,
          safe: 'active',
          image_size: :large,
          file_type: :jpg
        }
        results = Google::Search::Image.new(search_settings).to_a
        results.reject { |r| r.uri.include? 'getty' } # TODO: Put in conf
        return nil if results.empty?

        image = results.sample
        uri = results.sample.uri unless results.empty?

        return Ozorotter::PhotoData.new(
          source: 'google',
          image_url: image.uri,
          page_url: image.context_uri
        )
      rescue Exception => e
        puts e.message
      end
    end

    raise "Image search failed #{n_tries} in a row"
  end

  def flickr_search weather
    params = {
      lat: weather.lat,
      lon: weather.long,
      tags: "#{weather.category},#{weather.time_of_day}",
      tag_mode: 'all',
      extras: 'owner_name',
      safe_search: 1,
      accuracy: @config['accuracy'],
      radius: @config['radius'],
      license: @config['licenses'],
      group_id: @config['group_id'],
    }

    photos = flickr_search_params params

    # TODO: Refactor this ugly logic. Please. It's so bad.
    if photos.length < @photos_threshold
      puts 'Searching without day/night'
      params[:tags] = weather.category
      params.delete :tag_mode
      photos = flickr_search_params params
    end

    if photos.length < @photos_threshold
      puts 'Searching without group ID'
      params.delete :group_id
      photos = flickr_search_params params
    end

    if photos.length < @photos_threshold
      puts 'Searching text'
      params.delete :tags
      params.delete :lat
      params.delete :long

      params[:text] = "#{weather.location} #{weather.category} #{weather.time_of_day}"
      photos = flickr_search_params params
    end

    if photos.length < @photos_threshold
      puts 'Giving up and trying Google'
      return nil
    end

    photo = photos.sample
    url = FlickRaw.url photo
    page_url = FlickRaw.url_photopage(photo)
    puts photo.inspect
    puts url, page_url

    Ozorotter::PhotoData.new(
      source: 'flickr',
      image_url: url,
      page_url: page_url,
      short_url: "http://flic.kr/p/#{FlickRaw.base58 photo.id}",
      author: photo.ownername,
      title: photo.title
    )
  end

  def flickr_search_params params
    puts "Searching Flickr: #{params}"
    photos = flickr.photos.search(params).to_a
    puts "#{photos.length} photos matched."
    photos
  end
end

