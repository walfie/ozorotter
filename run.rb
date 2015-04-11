#!/usr/bin/env ruby
# Rake task runner that avoids using recently-used locations
# Usage: `ruby run.rb` (or `ruby run.rb --heroku` for Heroku's rake)
require 'yaml'

recent_path = 'output/recent.yml'
buffer_size = 8

recent = File.exists?(recent_path) ? YAML.load_file(recent_path) : []
locations = YAML.load_file('locations.yml')
new_location = (locations - recent).sample

cmd =
  if ARGV[0] == '--heroku'
    'heroku run rake'
  else
    'bundle exec rake'
  end

# Run the command, echoing to stdout
IO.popen("#{cmd} tweet['#{new_location}'] 2>&1") do |io|
  while line = io.gets do
    puts line
  end
end

# Update the recent locations
recent = recent.unshift(new_location).take(buffer_size)
File.open(recent_path, 'w') do |f|
  f.write recent.to_yaml
end

