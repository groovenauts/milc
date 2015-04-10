require "pry"

if ENV["COVERAGE"] =~ /true|yes|on|1/i
  require "simplecov"
  SimpleCov.start :rails
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'milc'
