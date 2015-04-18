require 'ozorotter/dal/wunderground'

RSpec.describe Ozorotter::Dal::Wunderground do
  Wunderground = Ozorotter::Dal::Wunderground

  describe '#get_weather' do
    let(:dao) { Wunderground.new('dummy_api_key', false) }

    it 'correctly parses the JSON' do
      json = %q({
        "current_observation": {
          "display_location": {
            "full": "New York, NY",
            "latitude":"40.75013351",
            "longitude":"-73.99700928"
          },
          "icon_url": "http://example.com/image.png",
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
        icon: "http://example.com/image.png",
        location: Ozorotter::Location.new({
          name: 'New York, NY',
          lat:"40.75013351",
          long:"-73.99700928"
        }),
        time: Time.at(1428187721).in_time_zone('America/New_York')
      )

      parsed = dao.get_weather('whatever')
      expect(parsed).to eq(expected)
    end
  end
end

