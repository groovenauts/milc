require "milc/gcloud/backend"

require 'logger'

require 'logger_pipe'

module Milc
  module Gcloud
    module Backend
      class GcloudCommand

        def execute(cmd)
          res = LoggerPipe.run(Milc.logger, cmd, dry_run: Milc.dry_run)
          block_given? ? yield(res) : res
        end

      end
    end
  end
end
