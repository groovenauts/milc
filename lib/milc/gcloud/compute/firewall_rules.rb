# coding: utf-8

require "milc/gcloud/compute"

require 'active_support/core_ext/array/wrap'

module Milc
  module Gcloud
    module Compute
      module FirewallRules
        def compare(attrs, res)
          attrs = attrs.dup
          Milc.logger.debug("*" * 100)
          [:allow, :source_ranges, :target_tags].each do |k|
            attrs[k] = split_sort(attrs[k])
          end
          res = res.symbolize_keys
          res[:allow] = res[:allowed].map{|h|
            proto = h["IPProtocol"]
            if ports = h["ports"]
              ports.map{|port| '%s:%s' % [proto, port] }
            else
              [proto]
            end
          }.tap(&:flatten!).sort
          {
            :sourceRanges => :source_ranges,
            :targetTags   => :target_tags,
          }.each do |k1, k2|
            res[k2] = res[k1] ? Array.wrap(res[k1]).sort : nil
          end
          super(attrs, res)
        end

        def call_update(cmd_args, attrs, &block)
          attrs = attrs.reject{|k,v| k == :network}
          super(cmd_args, attrs, &block)
        end
      end
    end
  end
end
