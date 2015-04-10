require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec


module Bundler
  class GemHelper
    def version_tag
      d = File.basename(File.dirname(__FILE__))
      "#{d}/#{version}"
    end
  end
end
