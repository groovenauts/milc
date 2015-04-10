# coding: utf-8

require "milc"

require 'active_support/hash_with_indifferent_access'

module Milc
  module Gcloud
    autoload :Resource, 'milc/gcloud/resource'
    autoload :Backend , 'milc/gcloud/backend'

    autoload :Compute , 'milc/gcloud/compute'
    autoload :Sql     , 'milc/gcloud/sql'
    autoload :Dns     , 'milc/gcloud/dns'

    class << self
      def backend
        @backend ||= Milc::Gcloud::Backend::GcloudCommand.new
      end
    end

  end
end
