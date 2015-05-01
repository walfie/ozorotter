require 'ozorotter/dal/yahoo_weather'

RSpec.describe Ozorotter::Dal::YahooWeather do
  YahooWeather = Ozorotter::Dal::YahooWeather

  let(:dao) { YahooWeather.new(false) }
  let(:json) {
    # This is pretty messy
    %q({
     "query": {
      "count": 1,
      "created": "2015-05-01T02:24:29Z",
      "lang": "en-US",
      "results": {
       "channel": {
        "location": {
         "city": "New York",
         "country": "United States",
         "region": "NY"
        },
        "atmosphere": {
         "humidity": "55",
         "pressure": "1012.7",
         "rising": "1",
         "visibility": "16.09"
        },
        "item": {
         "lat": "40.72",
         "long": "-74.01",
         "condition": {
          "code": "29",
          "date": "Thu, 30 Apr 2015 9:50 pm EDT",
          "temp": "12",
          "text": "Partly Cloudy"
         },
         "description": "\n<img src=\"http://l.yimg.com/a/i/us/we/52/29.gif\"/><br />\n<b>Current Conditions:</b><br />\nPartly Cloudy, 12 C<BR />\n<BR /><b>Forecast:</b><BR />\nThu - Cloudy. High: 16 Low: 9<br />\nFri - Cloudy. High: 15 Low: 9<br />\nSat - Partly Cloudy. High: 21 Low: 11<br />\nSun - Mostly Sunny. High: 24 Low: 13<br />\nMon - Mostly Sunny. High: 27 Low: 16<br />\n<br />\n<a href=\"http://us.rd.yahoo.com/dailynews/rss/weather/New_York__NY/*http://weather.yahoo.com/forecast/USNY0996_c.html\">Full Forecast at Yahoo! Weather</a><BR/><BR/>\n(provided by <a href=\"http://www.weather.com\" >The Weather Channel</a>)<br/>\n"
        }
       }
      }
     }
    })
  }
  let(:parsed_json) { JSON.parse(json) }

  describe '#get_weather_from_geo' do
    it 'correctly parses the JSON' do
      allow(dao).to receive(:get_json) { parsed_json }

      expected = Ozorotter::Weather.new(
        temperature: Ozorotter::Temperature.new(12.0),
        description: 'Partly Cloudy',
        humidity: '55%',
        icon: 'http://l.yimg.com/a/i/us/we/52/29.gif',
        location: Ozorotter::Location.new({
          name: "New York\nNY, United States",
          lat: 40.72,
          long: -74.01
        }),
        time: nil
      )

      parsed = dao.get_weather_from_geo(40.72, -74.01)
      expect(parsed).to eq(expected)
    end
  end
end



