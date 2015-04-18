require 'ozorotter/dal/flickr'

RSpec.describe Ozorotter::Dal::Flickr do
  Flickr = Ozorotter::Dal::Flickr

  describe '#search' do
    context "Flickr doesn't return enough photos" do
      let(:flickr) do
        flickraw = double(:flickr)
        allow(flickraw).to receive_message_chain('photos.search') { [1, 2, 3] }
        Flickr.new(flickraw, { photos_threshold: 5 }, false)
      end

      it 'returns nil' do
        photos = flickr.search(Ozorotter::Weather.new)
        expect(photos).to be_nil
      end
    end

    # TODO: More specs, maybe
  end
end

