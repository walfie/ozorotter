require 'ozorotter/dal/open_weather_map'

RSpec.describe Ozorotter::Dal::OpenWeatherMap do
  OWM = Ozorotter::Dal::OpenWeatherMap

  let(:dao) { OWM.new('dummy_api_key', false) }
  let(:json) {
    %q({
      "coord": { "lon": 139.69, "lat": 35.69 },
      "sys": { "country": "JP" },
      "weather": [{
        "main": "Rain",
        "description": "light rain",
        "icon": "10d"
      }],
      "main": { "temp": 15.21, "humidity": 97 },
      "dt": 1429581438,
      "name": "Tokyo"
    })
  }
  let(:parsed_json) { JSON.parse(json) }

  describe '#get_weather' do
    it 'correctly parses the JSON' do
      allow(dao).to receive(:get_json) { parsed_json }

      expected = Ozorotter::Weather.new(
        temperature: Ozorotter::Temperature.new(15.21),
        description: 'Light Rain',
        humidity: '97%',
        icon: 'http://openweathermap.org/img/w/10d.png',
        location: Ozorotter::Location.new({
          name: 'Tokyo, JP',
          lat: 35.69,
          long: 139.69
        }),
        time: nil,
        time_of_day: 'day'
      )

      parsed = dao.get_weather('tokyo')
      expect(parsed).to eq(expected)
    end
  end

  describe '#parse_api_response' do
    context 'icon does not contain "n"' do
      it 'sets time_of_day to day' do
        parsed_json['weather'][0]['icon'] = '10d'
        weather = dao.parse_api_response(parsed_json)
        expect(weather.time_of_day).to eq('day')
      end
    end

    context 'icon contains "n"' do
      it 'sets time_of_day to night' do
        parsed_json['weather'][0]['icon'] = '10n'
        weather = dao.parse_api_response(parsed_json)
        expect(weather.time_of_day).to eq('night')
      end
    end
  end
end


