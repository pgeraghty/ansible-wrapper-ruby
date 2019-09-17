require 'ansible/safe_pty'

module Ansible::PlaybookMethods
  BIN = 'ansible-playbook'

  def playbook pb
    `#{config.to_s "#{BIN} #{pb}"}`
  end
  alias :<< :playbook

  def stream pb
    # Use PTY because otherwise output is buffered
    Ansible::SafePty.spawn config.to_s("#{BIN} #{pb}") do |r,w,p| # add -vvvv here for verbose
      until r.eof? do
        line = r.gets
        block_given? ? yield(line) : puts(line)

        raise "FAILED: #{line}" if line.include?('fatal: [')
        # TODO raise if contains FAILED!
        # TODO raise if contains ERROR!
      end
    end
  end
end

module Ansible
  module Playbook
    include Ansible::Config
    include Ansible::PlaybookMethods

    extend self
    alias :run :playbook
  end
end