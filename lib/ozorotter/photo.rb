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

    # Image credits for tweets
    def credits
      if source == 'flickr'
        credits = %Q{Source: "#{title}" by #{author} on Flickr}

        # Assume '@username' plus the t.co URL take up 40 characters max
        if credits.length > 100 # TODO: Make this configurable
          credits = %Q{Source: Photo by #{author} on Flickr}
        end
        credits.gsub!('@', ' ')
        credits += "\n#{page_url}"
      else
        "Source: #{image_url} via #{page_url}"
      end
    end
  end
end


