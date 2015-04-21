require 'ozorotter/photo'

require 'ostruct'

RSpec.describe Ozorotter::Photo do
  describe '#initialize' do
    it 'sets attributes based on hash argument' do
      opts = {
        author: 'Potte',
        image_url: 'http://example.com/image.jpg',
        page_url: 'http://example.com/images',
        short_url: 'http://example.com/this-url-is-pretty-short',
        source: 'flickr',
        title: 'Tamayura!'
      }
      photo = Ozorotter::Photo.new(opts)

      opts.each do |k, v|
        expect(photo.send(k.to_sym)).to eq(v)
      end
    end
  end

  describe '.from_flickr_photo' do
    it 'initializes a photo with the proper values' do
      flickr_photo = OpenStruct.new(
        farm: 1,
        id: '12345',
        owner: 'owner_id_here',
        ownername: 'Walfie',
        secret: 'secret_here',
        server: 'server_here',
        title: 'Aikatsu!',
      )

      photo = Ozorotter::Photo.from_flickr_photo(flickr_photo)
      expected = Ozorotter::Photo.new(
        author: 'Walfie',
        image_url: 'https://farm1.staticflickr.com/server_here/12345_secret_here.jpg',
        page_url: 'https://www.flickr.com/photos/owner_id_here/12345',
        short_url: 'http://flic.kr/p/4ER',
        source: 'flickr',
        title: 'Aikatsu!'
      )

      expect(photo).to eq(expected)
    end
  end
end

