require 'ozorotter/temperature'

RSpec.describe Ozorotter::Temperature do
  describe '#initialize' do
    subject(:temp) { Ozorotter::Temperature.new(5.0) }

    it 'sets celsius and fahrenheit to the proper values' do
      expect(temp.celsius).to be_within(0.001).of(5.0)
      expect(temp.fahrenheit).to be_within(0.001).of(41.0)
    end
  end

  describe '#to_s' do
    subject(:temp) { Ozorotter::Temperature.new(3.1415) }

    context 'when no argument provided' do
      it 'rounds to 1 decimal places of precision' do
        expect(temp.to_s).to eq('3.1°C | 37.7°F')
      end
    end

    context 'when argument n provided' do
      it 'rounds to n decimal places of precision' do
        expect(temp.to_s(3)).to eq('3.142°C | 37.655°F')
      end
    end
  end

  describe '#==' do
    subject(:temp) { Ozorotter::Temperature.new(3.1415) }

    context 'when same celsius' do
      it 'returns true' do
        new_temp = Ozorotter::Temperature.new(3.1415)
        expect(temp == new_temp).to be(true)
      end
    end

    context 'when different celsius' do
      it 'returns false' do
        new_temp = Ozorotter::Temperature.new(1.23)
        expect(temp == new_temp).to be(false)
      end
    end

    context 'when different class' do
      require 'ostruct'

      it 'returns false' do
        new_temp = OpenStruct.new(celsius:3.1415)
        expect(temp == new_temp).to be(false)
      end
    end
  end
end

