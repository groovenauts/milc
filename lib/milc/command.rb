# coding: utf-8
require 'milc'

require 'optparse'

module Milc
  class Command

    attr_reader :logic
    def initialize(logic)
      @logic = logic
    end

    def run(args)
      setup(args)
      logic.process
      # exit 0
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

    # overriden
    def command_options
      "nVc:" # n と V と c: は必須
    end

    def show_help_and_exit1
      ## シェルスクリプトのUsage
      $stderr.puts logic.help_message
      exit 1
    end

    def load_options(options)
      if options["c"]
        yaml_path = options["c"]
        logic.config = YAML.load_file_with_erb(yaml_path)
        logic.load_config
      else
        show_help_and_exit1
      end
      logic.load_options(options)
    end

  end
end
