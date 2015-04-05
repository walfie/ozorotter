require 'google-search'

module Ozorotter::Search
  module_function
  def categorize_search term
    word = case term.downcase
    when /storm/ then 'stormy'
    when /rain|drizzle/ then 'rainy'
    when /snow|ice|hail/ then 'snowy'
    when /mist|fog|haze/ then 'foggy'
    when /cloud|overcast/ then 'cloudy'
    when /clear/ then 'clear sky'
    else term
    end
  end

  def search location, description, n_tries=5
    query = "#{location} #{categorize_search description}"
    puts "Searching '#{query}'"

    n_tries.times do
      begin
        search_settings = {
          query: query,
          safe: 'active',
          image_size: :medium,
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

