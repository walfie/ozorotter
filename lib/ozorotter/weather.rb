require 'ozorotter/location'
require 'ozorotter/temperature'
require 'ozorotter/util/object_from_hash'

module Ozorotter
  class Weather
    include ObjectFromHash

    attr_reader :description, :icon, :humidity, :location, :temperature, :time

    def initialize(opts={})
      defaults = {
        description: '',
        location: Ozorotter::Location.new,
        temperature: Ozorotter::Temperature.new(0),
        time_of_day: nil
      }
      super(defaults.merge(opts))
    end

    # Human-readable time, including time zone and day of week
    def time_string
      return '' if time.nil?
      time.strftime "%a %-I:%M%p (%Z)\n%Y/%m/%d"
    end

    # If @time_of_day is set (in the initializer), return that value.
    #
    # Otherwise:
    # Returns 'day' or 'night' (or `nil` if `time` is `nil`)
    # Considers 6:00am to 6:59pm to be daytime, otherwise nighttime
    def time_of_day
      return @time_of_day if @time_of_day
      return nil if time.nil?

      time.hour.between?(6, 18) ? 'day' : 'night'
    end

    # Weather category based on ProjectWeather tags:
    # https://www.flickr.com/groups/1463451@N25/discuss/72157633275888770/72157633276043030
    def category
      @category ||=
        case description.downcase
        when /rain|drizzle|shower/ then 'rain'
        when /snow|ice|hail/ then 'snow'
        when /thunderstorm/ then 'storm'
        when /cloud|overcast/ then 'cloudy'
        when /clear/ then 'clear'
        when /mist|fog|haze|smoke|ash|dust|sand|spray/ then 'fog'
        else description.downcase
        end
    end

    def to_s
      [
        location.name,
        "#{temperature.to_s}",
        "Humidity: #{humidity}",
        description
      ].join("\n")
    end
  end
end

