module Ozorotter
  Weather = Struct.new :time, :location, :description, :celsius do
    def fahrenheit
      celsius * 9/5 + 32
    end
  end
end

