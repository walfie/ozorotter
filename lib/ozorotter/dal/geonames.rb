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
      region = geoname['adminName1']
      region = nil if region.to_s == ''

      name = [geoname['name'], region].compact.join(', ')

      Ozorotter::Location.new(
        lat: geoname['lat'].to_f,
        long: geoname['lng'].to_f,
        name: "#{name}\n#{geoname['countryName']}"
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
        STDERR.puts "Geonames invalid response: #{parsed_json}"
        raise Ozorotter::Errors::ServerError.new(url), 'Probably rate limited'
      end
    end
  end
end

