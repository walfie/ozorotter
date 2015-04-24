require 'ozorotter/location'

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
      parse_geoname(json['geonames'].first)
    end

    def parse_geoname(geoname)
      Ozorotter::Location.new(
        lat: geoname['lat'].to_f,
        long: geoname['lng'].to_f,
        name: "#{geoname['name']}, #{geoname['countryName']}"
      )
    end

    def get_json(url)
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      parsed_json = JSON.parse(response.body)

      if parsed_json['geonames'] && !parsed_json['geonames'].empty?
        parsed_json
      else
        raise Ozorotter::Errors::ServerError.new(url), 'Probably rate limited'
      end
    end
  end
end
