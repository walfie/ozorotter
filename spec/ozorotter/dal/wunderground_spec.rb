require 'ozorotter/dal/wunderground'

RSpec.describe Ozorotter::Dal::Wunderground do
  Wunderground = Ozorotter::Dal::Wunderground

  let(:dao) { Wunderground.new('dummy_api_key', false) }

  describe '#get_weather' do
    it 'correctly parses the JSON' do
      json = %q({
        "current_observation": {
          "display_location": {
            "full": "New York, NY",
            "latitude":"40.75013351",
            "longitude":"-73.99700928"
          },
          "icon_url": "http://example.com/nt_image.png",
          "local_epoch": "1428187721",
          "local_tz_long": "America/New_York",
          "relative_humidity": "50%",
          "temp_c": 10.0,
          "weather":"Partly Cloudy"
        }
      })
      allow(dao).to receive(:get_json) { JSON.parse(json) }

      expected = Ozorotter::Weather.new(
        temperature: Ozorotter::Temperature.new(10.0),
        description: 'Partly Cloudy',
        humidity: '50%',
        icon: "http://example.com/nt_image.png",
        location: Ozorotter::Location.new({
          name: 'New York, NY',
          lat:"40.75013351",
          long:"-73.99700928"
        }),
        time: Time.at(1428187721).in_time_zone('America/New_York'),
        time_of_day: 'night'
      )

      parsed = dao.get_weather('whatever')
      expect(parsed).to eq(expected)
    end
  end

  describe '#parse_observation_hash' do
    context 'icon_url does not contain "nt_"' do
      it 'sets time_of_day to day' do
        weather = dao.parse_observation_hash(
          'temp_c' => 0,
          'icon_url' => 'http://example.com/cloudy.png'
        )
        expect(weather.time_of_day).to eq('day')
      end
    end

    context 'icon_url contains "nt_"' do
      it 'sets time_of_day to night' do
        weather = dao.parse_observation_hash(
          'temp_c' => 0,
          'icon_url' => 'http://example.com/nt_cloudy.png'
        )
        expect(weather.time_of_day).to eq('night')
      end
    end
  end
end

