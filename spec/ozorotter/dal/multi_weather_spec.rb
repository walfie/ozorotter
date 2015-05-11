require 'ozorotter/dal/multi_weather'

RSpec.describe Ozorotter::Dal::MultiWeather do
  MultiWeather = Ozorotter::Dal::MultiWeather

  let(:nil_api) do
    allow(api = double).to receive(:some_method).and_return(nil)
    api
  end

  let(:fail_api) do
    allow(api = double).to receive(:some_method).and_raise('some error')
    api
  end

  let(:successful_api) do
    allow(api = double).to receive(:some_method).and_return('not an error')
    api
  end

  let(:never_called_api) { double }

  describe '#get_first_success' do
    it 'returns the first successful element' do
      apis = [fail_api, nil_api, successful_api, never_called_api]
      dao = MultiWeather.new(apis)

      expect(fail_api).to receive(:some_method)
      expect(nil_api).to receive(:some_method)
      expect(successful_api).to receive(:some_method)
      expect(never_called_api).to_not receive(:some_method)

      result = dao.get_first_success(:some_method, 'some arg')
      expect(result).to eq('not an error')
    end
  end

  # Assume `get_weather` and `get_weather_from_geo` call `get_first_success`
end

