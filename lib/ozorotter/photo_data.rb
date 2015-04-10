module Ozorotter
  class PhotoData
    attr_reader :source, :image_url, :page_url, :author, :title, :short_url

    def initialize args
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
  end
end

