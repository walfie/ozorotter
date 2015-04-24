require 'ozorotter/location'
require 'ozorotter/dal/geonames'

RSpec.describe Ozorotter::Dal::Geonames do
  Geonames = Ozorotter::Dal::Geonames

  describe '#get_location' do
    let(:geonames) { Geonames.new('whatever') }
    let(:json) do
      %q{{
        "totalResultsCount": 1737,
        "geonames": [{
          "countryId": "1861060",
          "adminCode1": "40",
          "countryName": "Japan",
          "fclName": "city, village,...",
          "countryCode": "JP",
          "lng": "139.69171",
          "fcodeName": "capital of a political entity",
          "toponymName": "Tokyo",
          "fcl": "P",
          "name": "Tokyo",
          "fcode": "PPLC",
          "geonameId": 1850147,
          "lat": "35.6895",
          "adminName1": "Tōkyō",
          "population": 8336599
        }]
      }}
    end

    it 'returns the location' do
      allow(geonames).to receive(:get_json) { JSON.parse(json) }

      expected = Ozorotter::Location.new(
        lat: 35.6895,
        long: 139.69171,
        name: "Tokyo, Tōkyō\nJapan"
      )

      expect(geonames.get_location('Tokyo')).to eq(expected)
    end

    # TODO: Test absence of adminName1
  end
end


