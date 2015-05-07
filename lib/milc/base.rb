# coding: utf-8

require "milc"

require 'erb'
require 'yaml'

require 'logger_pipe'

def YAML.load_file_with_erb(yaml_path)
  erb = ERB.new(IO.read(yaml_path))
  erb.filename = yaml_path
  text = erb.result
  YAML.load(text)
end

module Milc
  module Base

    def logger
      Milc.logger
    end

    def execute(cmd, options = {})
      options[:dry_run] = Milc.dry_run
      res = LoggerPipe.run(logger, cmd, options)
      block_given? ? yield(res) : res
    end

    attr_accessor :config
    attr_reader :project

    def dry_run
      Milc.dry_run
    end

    # overriden
    def load_config
      @project = config['PROJECT'] || ENV['PROJECT']
    end

    # overriden
    def help_message
      ## スクリプト名
      cmdname = File.basename($0) # $PROGRAM_NAME を推奨
      ## シェルスクリプトのUsage
      "Usage: #{cmdname} -c CONF_FILE"
    end

    # overriden
    def load_options(options)
    end

  end
end
