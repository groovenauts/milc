# coding: utf-8

require "milc/gcloud"

module Milc
  module Gcloud
    module Compute
      autoload :FirewallRules, 'milc/gcloud/compute/firewall_rules'
      autoload :Instances    , 'milc/gcloud/compute/instances'
      autoload :TargetPools  , 'milc/gcloud/compute/target_pools'
    end
  end
end
