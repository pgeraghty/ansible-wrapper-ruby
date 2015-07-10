module Ansible
  module AdHoc
    extend self
    BIN = 'ansible'

    def run(cmd, opts={})
      cmds = [BIN, cmd]

      if opts[:skip_host_key_checking]
        cmds << 'ANSIBLE_HOST_KEY_CHECKING=False'
      end

      `#{cmds*' '}`
    end
  end
end