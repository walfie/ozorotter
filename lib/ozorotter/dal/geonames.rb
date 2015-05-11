require 'ozorotter/location'

require 'active_support/core_ext/object/blank'
require 'json'
require 'open-uri'
require 'net/http'

module Ozorotter::Dal
  class Geonames
    def initialize(username)
      @username = username
    end

    def get_location(search_term)
      url = "http://api.geonames.org/searchJSON?q=#{URI.escape(search_term)}&maxRows=1&username=#{@username}"
      json = get_json(url)

      return nil if json['geonames'].empty? # Don't know this place

      if json['geonames'].nil?
        STDERR.puts "Geonames: Invalid response for '#{search_term}' #{json.inspect}"
        raise Ozorotter::Errors::ServerError.new(url), 'Probably rate limited'
      end

      parse_geoname(json['geonames'].first)
    end

    def get_timezone(lat, long)
      url = "http://api.geonames.org/timezoneJSON?lat=#{lat}&lng=#{long}&username=#{@username}"
      json = get_json(url)

      json['timezoneId'] # Might be nil
    end

    def parse_geoname(geoname)
      region = geoname['adminName1'].presence
      country = geoname['countryName'].presence # Antarctica has a blank countryName

      region_and_country = [region, country].compact.join(', ')

      Ozorotter::Location.new(
        lat: geoname['lat'].to_f,
        long: geoname['lng'].to_f,
        name: "#{geoname['name']}\n#{region_and_country}"
      )
    end

    def get_json(url)
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      JSON.parse(response.body)
    end
  end
end

