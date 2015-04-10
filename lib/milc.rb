require "milc/version"

require 'logger'

module Milc
  autoload :Base, 'milc/base'
  autoload :Dsl , 'milc/dsl'

  autoload :Gcloud, 'milc/gcloud'

  class << self
    attr_accessor :dry_run

    attr_reader :verbose
    def verbose=(value)
      @verbose = value
      logger.level = @verbose ? Logger::DEBUG : Logger::INFO
      value
    end

    def logger
      unless @logger
        @logger = Logger.new($stdout)
        @logger.level = Logger::INFO
      end
      @logger
    end
  end
end
