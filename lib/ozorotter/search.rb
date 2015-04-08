require 'google-search'
require 'flickraw'

module Ozorotter::Search
  module_function

  FlickRaw.api_key = ENV['FLICKR_KEY']
  FlickRaw.shared_secret = ENV['FLICKR_SECRET']

  # TODO: Better config management
  @config ||= YAML.load_file('config.yml')['flickr']
  @photos_threshold = @config['photos_threshold']

  def google_search location, description, n_tries=5
    query = "#{location} #{description}"
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
        uri = results.sample.uri unless results.empty?
        return uri
      rescue Exception => e
        puts e.message
      end
    end

    raise "Image search failed #{n_tries} in a row"
  end

  def flickr_search lat, long, tags
    params = {
      lat: lat,
      lon: long,
      tags: tags || 'weather',
      tag_mode: 'all',
      extras: 'owner_name',
      accuracy: @config['accuracy'],
      radius: @config['radius'],
      license: @config['licenses'],
      group_id: @config['group_id']
    }

    photos = flickr_search_params params

    # TODO: Refactor this ugly logic. Please. It's so bad.
    if photos.length < @photos_threshold
      puts 'Searching without day/night'
      params[:tags] = params[:tags].sub(/day|night|sunset|sunrise/, '')
      params.delete :tag_mode
      photos = flickr_search_params params
    end

    if photos.length < @photos_threshold
      puts 'Searching without group ID'
      params.delete :group_id
      params[:tags] = params[:tags].sub('clear', 'clear sky')
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

    { image_url: url, page_url: page_url, author: photo.ownername, title: photo.title }
  end

  def flickr_search_params params
    puts 'Searching Flickr:', params
    photos = flickr.photos.search(params).to_a
    puts "#{photos.length} photos matched."
    photos
  end
end

