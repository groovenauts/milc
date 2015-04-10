# coding: utf-8

require "milc"

module Milc
  module Dsl
    autoload :Gcloud  , 'milc/dsl/gcloud'
    autoload :Mgcloud , 'milc/dsl/mgcloud'

    autoload :Ansible, 'milc/dsl/ansible'
  end
end
