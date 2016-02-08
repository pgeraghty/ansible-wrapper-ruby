require 'ansible/safe_pty'

module Ansible
  module Playbook
    BIN = 'ansible-playbook'
    extend self

    def run(cmd, _opts={})
      cmd_line =  [Ansible.env_string, 'ANSIBLE_FORCE_COLOR=True', BIN, cmd]*' '

      `#{cmd_line}`
    end

    # This method uses PTY because otherwise output is buffered
    def stream(cmd, _opts={})
      cmd_line = [Ansible.env_string, 'ANSIBLE_FORCE_COLOR=True', BIN, cmd]*' '

      SafePty.spawn(cmd_line) do |r,_w,_p|
        block_given? ? yield(r.gets) : puts(r.gets) until r.eof?
      end
    end
  end
end