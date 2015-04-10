# coding: utf-8

require "milc/gcloud/compute"

require 'active_support/core_ext/array/wrap'

module Milc
  module Gcloud
    module Compute
      module Instances
        def build_attr_arg(attr_name, value)
          case attr_name
          when :disk, :disks then
            disks = Array.wrap(value).map{|d| d.is_a?(Hash) ? build_sub_attr_args(d) : d.to_s }
            disks.map{|d| "--disk #{d}"}.join(" ")
          else
            super(attr_name, value)
          end
        end

        def first_internal_ip(network_interfaces)
          network_interfaces.map{|i| i["networkIP"]}.compact.first
        end
        module_function :first_internal_ip

        def first_external_ip(network_interfaces)
          network_interfaces.map{|i|
            configs = i["accessConfigs"] || []
            configs.map{|c| c["natIP"] }.compact.first
          }.flatten.first
        end
        module_function :first_external_ip
      end
    end
  end
end
