module Ozorotter::Dal
  class MultiWeather
    def initialize(weather_services=[])
      @weather_apis = weather_services
    end

    def get_weather(*args)
      get_first_success(:get_weather, *args)
    end

    def get_weather_from_geo(*args)
      get_first_success(:get_weather_from_geo, *args)
    end

    def get_first_success(method_name, *args)
      results = @weather_apis.lazy.map do |weather_api|
        begin
          weather_api.public_send(method_name, *args)
        rescue Exception => e
          STDERR.puts "#{weather_api.class.to_s} failed: #{e.inspect}"
          STDERR.puts e.backtrace.take(10).map { |s| "\t"+s }.join("\n")

          nil
        end
      end

      results.reject(&:nil?).first
    end
  end
end

