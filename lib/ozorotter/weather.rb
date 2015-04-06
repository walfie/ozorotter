module Ozorotter
  Weather = Struct.new :time, :location, :description, :celsius, :humidity, :icon do
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
  end
end

