require 'ozorotter/location'

RSpec.describe Ozorotter::Location do
  describe '#initialize' do
    subject(:loc) do
      opts = { lat: 12, long: 34, name: 'Place Name' }
      Ozorotter::Location.new(opts)
    end

    it 'sets attributes based on hash argument' do
      expect(loc.lat).to eq(12)
      expect(loc.long).to eq(34)
      expect(loc.name).to eq('Place Name')
    end
  end
end


