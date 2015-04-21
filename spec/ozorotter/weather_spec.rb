require 'ozorotter/weather'
require 'active_support/core_ext/time'

RSpec.describe Ozorotter::Weather do
  describe '#initialize' do
    it 'sets attributes based on hash argument' do
      opts = {
        description: 'Rainy',
        icon: 'http://example.com/image.png',
        humidity: '50%',
        location: double('location'),
        temperature: double('temperature'),
        time: Time.new
      }

      weather = Ozorotter::Weather.new(opts)

      opts.each do |k, v|
        expect(weather.send(k.to_sym)).to eq(v)
      end
    end
  end

  describe '#time_string' do
    context 'time is defined' do
      subject(:weather) do
        time = Time.utc(2015, 4, 16, 3, 8).in_time_zone('America/New_York')
        Ozorotter::Weather.new(time: time)
      end

      it 'returns the date in the appropriate format' do
        expect(weather.time_string).to eq("Wed 11:08PM (EDT)\n2015/04/15")
      end
    end

    context 'time is nil' do
      subject(:weather) { Ozorotter::Weather.new }

      it 'returns an empty string' do
        expect(weather.time_string).to eq('')
      end
    end
  end

  describe '#time_of_day' do
    cases = [
      { given: Time.utc(2015, 4, 15,  5, 59), expect: 'night'},
      { given: Time.utc(2015, 4, 15,  6,  0), expect: 'day'},
      { given: Time.utc(2015, 4, 15, 18, 59), expect: 'day'},
      { given: Time.utc(2015, 4, 15, 19,  0), expect: 'night'}
    ]

    cases.each do |c|
      context "when time is #{c[:given]}" do
        subject(:weather) { Ozorotter::Weather.new(time: c[:given]) }

        it "returns #{c[:expect]}" do
          expect(weather.time_of_day).to eq(c[:expect])
        end
      end
    end

    context 'time is nil' do
      subject(:weather) { Ozorotter::Weather.new }

      it 'returns nil' do
        expect(weather.time_of_day).to be_nil
      end
    end
  end

  describe '#category' do
    context "when the description matches no known categories" do
      subject(:weather) { Ozorotter::Weather.new(description: 'Hello') }

      it 'returns downcased input' do
        expect(weather.category).to eq('hello')
      end
    end
  end
end

