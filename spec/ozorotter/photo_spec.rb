require 'ozorotter/photo'

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
end



