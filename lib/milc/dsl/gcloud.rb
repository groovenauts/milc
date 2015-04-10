require "milc/dsl"

module Milc::Dsl
  module Gcloud

    def gcloud(cmd, &block)
      execute(build_gcloud_command(cmd), returns: :none, logging: :both, &block)
    end

    def json_gcloud(cmd)
      r = execute(build_gcloud_command(cmd + " --format json"), returns: :stdout, logging: :stderr)
      res = r.nil? ? nil : JSON.parse(r)
      block_given? ? yield(res) : res
    end

    def build_gcloud_command(cmd)
      r = "gcloud #{cmd}"
      r << " --project #{project}" unless cmd =~ /\s\-\-project[\s\=]/
      r
    end

  end
end
