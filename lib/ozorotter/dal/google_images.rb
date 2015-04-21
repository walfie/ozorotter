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

    def search(weather, n_tries=5)
      query = "#{weather.location.name} #{adjust_terms(weather.category)} #{weather.time_of_day}"

      # Retry a few times in case we get an error 
      n_tries.times do
        begin
          search_settings = {
            query: query,
            safe: 'active',
            image_size: :large,
            file_type: :jpg
          }
          results = Google::Search::Image.new(search_settings).to_a
          results.reject { |r| r.uri.include?('getty') } # TODO: Put in conf
          return nil if results.empty?
          puts "Searching Google: #{query} (#{results.length})" if @logging_enabled

          image = results.sample
          uri = results.sample.uri unless results.empty?
          puts uri if @logging_enabled

          return Ozorotter::Photo.new(
            source: 'google',
            image_url: image.uri,
            page_url: image.context_uri
          )
        rescue Exception => e
          puts e.message
        end
      end

      nil # Give up
    end
  end
end

