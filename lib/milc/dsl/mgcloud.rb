require "milc/dsl"

module Milc::Dsl
  module Mgcloud

    def mgcloud(cmd, attrs = {}, &block)
      service, resource, action, cmd_args = cmd.lstrip.split(/\s+/, 4)
      resource = Milc::Gcloud::Resource.lookup(project, service, resource)
      resource.send(action.gsub(/-/, '_'), cmd_args, attrs, &block)
    end

  end
end
