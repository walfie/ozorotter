require 'ozorotter/bot/weather_bot'

RSpec.describe Ozorotter::Bot::WeatherBot do
  WeatherBot = Ozorotter::Bot::WeatherBot

  describe '.parse_weather' do
    cases = [
      { given: "nyc weather", expect: 'nyc' },
      { given: "New York weather", expect: 'New York' },

      { given: "weather New York, US", expect: 'New York, US' },
      { given: "weather New York", expect: 'New York' },
      { given: "weather for New York", expect: 'New York' },
      { given: "what's the weather in New York?", expect: 'New York' },
      { given: "@user what's the weather like in New York?", expect: 'New York' },
      { given: "weather New York! I can put anything here", expect: 'New York' },
      { given: "weather 東京", expect: '東京' },

      { given: "London, UKの天気", expect: 'London, UK' },
      { given: "東京の天気", expect: '東京' },
      { given: "東京のお天気", expect: '東京' },
      { given: "東京のお天気は？", expect: '東京' },
      { given: "@user 東京のお天気は？", expect: '東京' },

      { given: "weather", expect: nil },
      { given: "weather?", expect: nil },
      { given: "東京 天気", expect: nil },
      { given: "東京 お天気", expect: nil },
      { given: "の天気", expect: nil },
      { given: "@user のお天気", expect: nil },
    ]

    cases.each do |c|
      context "when input is #{c[:given]}" do
        it "returns #{c[:expect]}" do
          expect(WeatherBot.parse_weather(c[:given])).to eq(c[:expect])
        end
      end
    end
  end
end

