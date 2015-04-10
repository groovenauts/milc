require "milc/dsl"

module Milc::Dsl
  module Gcloud

    def gcloud(cmd, &block)
      cmd << " --project #{project}" unless cmd =~ /\s\-\-project[\s\=]/
      execute("gcloud #{cmd}", &block)
    end

    def json_gcloud(cmd)
      r = gcloud(cmd + " --format json")
      res = r.nil? ? nil : JSON.parse(r)
      block_given? ? yield(res) : res
    end

  end
end
