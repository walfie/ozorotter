require 'ozorotter/photo'

require 'google/apis/customsearch_v1'

module Ozorotter::Dal
  class GoogleImages
    def initialize(api_key, cx, logging_enabled=true)
      @logging_enabled = logging_enabled
      @search = Google::Apis::CustomsearchV1::CustomsearchService.new
      @search.key = api_key
      @cx = cx
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
      results = @search.list_cses(
        query,
        cx: @cx,
        search_type: 'image',
        img_size: 'large',
        file_type: 'jpg',
        safe: 'medium'
      ).items

      results.reject! do |r| # TODO: Put in conf
        r.image.context_link.include?('getty') || r.link.include?('getty')
      end
      puts "Searching Google: #{query} (#{results.length})" if @logging_enabled

      return nil if results.empty?

      result = results.sample
      uri = result.link
      puts uri if @logging_enabled

      return Ozorotter::Photo.new(
        source: 'google',
        image_url: result.link,
        page_url: result.image.context_link
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

