require 'ozorotter/util/object_from_hash'

require 'flickraw'

module Ozorotter
  class Photo
    include ObjectFromHash

    attr_reader :author, :image_url, :page_url, :short_url, :source, :title

    def self.from_flickr_photo(photo)
      url = FlickRaw.url(photo)
      page_url = FlickRaw.url_photopage(photo)

      Ozorotter::Photo.new(
        author: photo.ownername,
        image_url: url,
        page_url: page_url,
        short_url: "http://flic.kr/p/#{FlickRaw.base58(photo.id)}",
        source: 'flickr',
        title: (photo.title.to_s.empty? ? 'Untitled' : photo.title)
      )
    end
  end
end


