require 'ozorotter/image_data'

RSpec.describe Ozorotter::ImageData do
  describe '#initialize' do
    subject(:image_data) do
      Ozorotter::ImageData.new(image: 'hello', photo: 'world', weather: '!')
    end

    it 'sets attributes based on hash argument' do
      expect(image_data.image).to eq('hello')
      expect(image_data.photo).to eq('world')
      expect(image_data.weather).to eq('!')
    end
  end
end



