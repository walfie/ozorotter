require 'google-search'

module Ozorotter::Search
  module_function

  def search location, description, n_tries=5
    query = "#{location} #{description}"
    puts "Searching '#{query}'"

    n_tries.times do
      begin
        search_settings = {
          query: query,
          safe: 'active',
          image_size: :large,
          file_type: :jpg
        }
        results = Google::Search::Image.new(search_settings).to_a
        uri = results.sample.uri unless results.empty?
        return uri
      rescue Exception => e
        puts e.message
      end
    end

    raise "Image search failed #{n_tries} in a row"
  end
end

