require 'ozorotter/util/object_from_hash'

module Ozorotter
  class Location
    include ObjectFromHash

    attr_reader :lat, :long, :name

    alias_method :latitude, :lat
    alias_method :longitude, :long
  end
end

