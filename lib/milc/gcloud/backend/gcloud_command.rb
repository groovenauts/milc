require "milc/gcloud/backend"

require 'logger'

require 'logger_pipe'

module Milc
  module Gcloud
    module Backend
      class GcloudCommand

        def execute(cmd, options = {})
          options[:dry_run] = Milc.dry_run
          res = LoggerPipe.run(Milc.logger, cmd, options)
          block_given? ? yield(res) : res
        end

      end
    end
  end
end
