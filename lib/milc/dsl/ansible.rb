require "milc/dsl"

module Milc::Dsl
  module Ansible

    def ansible_playbook(cmd, &block)
      # https://github.com/mitchellh/vagrant/blob/0098b7604d071948fd37b16dd10b87b6df49b624/plugins/provisioners/ansible/provisioner.rb#L58
      command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook #{cmd}"
      command << " -vvvv" if Milc.verbose
      execute(command, returns: :none, logging: :both, &block)
      nil
    end

  end
end
