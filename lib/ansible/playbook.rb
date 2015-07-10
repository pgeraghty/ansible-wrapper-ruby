require 'ansible/safe_pty'

module Ansible
  module Playbook
    BIN = 'ansible-playbook'
    extend self

    def run(cmd, opts={})
      cmds = [BIN, cmd]

      if opts[:skip_host_key_checking]
        cmds << 'ANSIBLE_HOST_KEY_CHECKING=False'
      end

      `#{cmds*' '}`
    end

    # This method uses PTY because otherwise output is buffered
    def stream(cmd, opts={}, &block)
      cmds = ['ANSIBLE_FORCE_COLOR=True', BIN, cmd]

      if opts[:skip_host_key_checking]
        cmds = ['ANSIBLE_HOST_KEY_CHECKING=False'] + cmds
      end

      SafePty.spawn(cmds*' ') { |r,w,p| yield r.gets until r.eof? }
    end
  end
end