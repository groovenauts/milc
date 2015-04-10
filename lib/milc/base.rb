# coding: utf-8

require "milc"

require 'json'
require 'erb'
require 'yaml'
require 'optparse'
require 'shellwords'

require 'logger_pipe'

def YAML.load_file_with_erb(yaml_path)
  erb = ERB.new(IO.read(yaml_path))
  erb.filename = yaml_path
  text = erb.result
  YAML.load(text)
end

module Milc
  module Base
    include Milc::Dsl::Gcloud
    include Milc::Dsl::Mgcloud

    include Milc::Dsl::Ansible

    def logger
      Milc.logger
    end

    def execute(cmd)
      res = LoggerPipe.run(logger, cmd, dry_run: Milc.dry_run)
      block_given? ? yield(res) : res
    end

    def load_from_yaml(yaml_path)
      @config = YAML.load_file_with_erb(yaml_path)
      load_config
    end

    attr_reader :config
    attr_reader :project

    def dry_run
      Milc.dry_run
    end

    def load_config
      @project = config['PROJECT'] || ENV['PROJECT']
    end

    def show_help_and_exit1
      ## シェルスクリプトのUsage
      $stderr.puts help_message
      exit 1
    end

    def help_message
      ## スクリプト名
      cmdname = File.basename($0) # $PROGRAM_NAME を推奨
      ## シェルスクリプトのUsage
      "Usage: #{cmdname} -c CONF_FILE"
    end

    def command_options
      "nVc:" # n と V と c: は必須
    end

    def load_options(options)
      if options["c"]
        load_from_yaml(options["c"])
      else
        show_help_and_exit1
      end
    end

    def setup(args)
      # ARGV.getopts については以下を参照
      # http://d.hatena.ne.jp/zariganitosh/20140819/ruby_optparser_true_power
      # http://docs.ruby-lang.org/ja/2.1.0/method/OptionParser=3a=3aArguable/i/getopts.html
      args.extend(OptionParser::Arguable) unless args.is_a?(OptionParser::Arguable)
      options = args.getopts(command_options)
      show_help_and_exit1 unless args.empty?

      Milc.dry_run = !!options["n"]
      Milc.verbose = !!options["V"]

      load_options(options)
    end

    def run(args)
      setup(args)
      process
      # exit 0
    end

  end
end
