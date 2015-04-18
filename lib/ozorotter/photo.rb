require 'ozorotter/util/object_from_hash'

module Ozorotter
  class Photo
    include ObjectFromHash

    attr_reader :author, :image_url, :page_url, :short_url, :source, :title
  end
end


