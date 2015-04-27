require 'ozorotter/photo'

require 'google-search'

module Ozorotter::Dal
  class GoogleImages
    def initialize(logging_enabled=true)
      @logging_enabled = logging_enabled
    end

    def adjust_terms(search_term)
      mappings = {
        'rain' => 'rainy',
        'snow' => '(snow OR snowy)',
        'storm' => 'storm',
        'clear' => 'clear (sky OR weather)',
        'fog' => '(fog OR foggy)'
      }
      term = mappings[search_term] || search_term
      term += ' -snow' unless term.include?('snow')
      term += ' -disaster -earthquake -tsunami -hurricane'
      term
    end

    def search(weather, n_tries=3)
      base_query = "#{adjust_terms(weather.category)} #{weather.time_of_day}"
      query_with_location = "#{weather.location.name} #{base_query}"

      search_query(query_with_location, n_tries) || search_query(base_query, n_tries)
    end

    def search_query(query, tries_remaining=3)
      search_settings = {
        query: query,
        safe: 'active',
        image_size: :large,
        file_type: :jpg
      }
      results = Google::Search::Image.new(search_settings).to_a
      results.reject! do |r| # TODO: Put in conf
        r.uri.include?('getty') || r.context_uri.include?('getty')
      end
      puts "Searching Google: #{query} (#{results.length})" if @logging_enabled

      return nil if results.empty?

      image = results.sample
      uri = results.sample.uri
      puts uri if @logging_enabled

      return Ozorotter::Photo.new(
        source: 'google',
        image_url: image.uri,
        page_url: image.context_uri
      )
    rescue Exception => e
      STDERR.puts "Failed: #{e.inspect}"

      if tries_remaining.zero?
        return nil
      else
        tries_remaining -= 1
        retry
      end
    end
  end
end

