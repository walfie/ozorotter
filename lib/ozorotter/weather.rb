module Ozorotter
  class Weather
    attr_reader :time, :location, :description, :celsius, :humidity, :icon, :lat, :long

    def initialize args
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def fahrenheit
      celsius * 9/5 + 32
    end

    def celsius_string
      celsius.round(1).to_s + '°C'
    end

    def fahrenheit_string
      fahrenheit.round(1).to_s + '°F'
    end

    def temperature_string
      celsius_string + ' | ' + fahrenheit_string
    end

    def time_string
      time.strftime "%a %-I:%M%p (%Z)\n%Y/%m/%d"
    end

    def categorize
      # Project Weather tags
      # https://www.flickr.com/groups/1463451@N25/discuss/72157633275888770/72157633276043030
      word = case description.downcase
      when /rain|drizzle|shower/ then 'rain'
      when /snow|ice|hail/ then 'snow'
      when /thunderstorm/ then 'storm'
      when /cloud|overcast/ then 'cloudy'
      when /clear/ then 'clear'
      when /mist|fog|haze|smoke|ash|dust|sand|spray/ then 'fog'
      else description.downcase
      end

      # sunrise, sunset, night, day
      # clear, cloudy, partlycloudy, rain, snow, storm, or fog
      # https://www.flickr.com/groups/1463451@N25/discuss/72157648737791827/72157649166434595
    end
  end
end

