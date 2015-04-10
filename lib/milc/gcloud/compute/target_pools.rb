# coding: utf-8

require "milc/gcloud/compute"

require 'active_support/core_ext/array/wrap'

module Milc
  module Gcloud
    module Compute
      module TargetPools
        def add_instances(cmd_args, attrs, &block)
          call_action("add-instances", cmd_args, attrs, &block)
        end

      end
    end
  end
end
