module Ozorotter
  class Temperature
    attr_reader :celsius, :fahrenheit

    def initialize(celsius)
      @celsius = celsius
      @fahrenheit = celsius * 9/5 + 32
    end

    def to_s(precision=1)
      c = celsius.round(precision).to_s + '°C'
      f = fahrenheit.round(precision).to_s + '°F'
      c + ' | ' + f
    end

    def ==(obj)
      obj.class == self.class && obj.celsius == self.celsius
    end
  end
end

