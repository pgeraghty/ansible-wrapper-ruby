require 'ansible/config'
require 'ansible/safe_pty'

module Ansible
  # Ansible Playbook methods
  module PlaybookMethods
    # executable that runs Ansible Playbooks
    BIN = 'ansible-playbook'

    # Run playbook, returning output
    # @param pb [String] path to playbook
    # @return [String] output
    def playbook(pb)
      # TODO if debug then puts w/ colour
      `#{config.to_s "#{BIN} #{pb}"}`
    end
    alias :<< :playbook

    # Stream execution of a playbook using PTY because otherwise output is buffered
    # @param pb [String] path to playbook
    # @return [Integer] exit status
    def stream(pb)
      cmd = config.to_s("#{BIN} #{pb}")

      SafePty.spawn cmd do |r,_,_| # add -vvvv here for verbose
        until r.eof? do
          line = r.gets
          block_given? ? yield(line) : puts(line)

          case line
            when /fatal: \[/ then raise Playbook::Exception.new("FAILED: #{line}")
            when /ERROR!/,/FAILED!/  then raise Playbook::Exception.new("ERROR: #{line}")
          end
        end
      end
    end
  end

  # Provides static access to Playbook methods
  module Playbook
    include Config
    include PlaybookMethods

    extend self

    # Run playbook, returning output
    # @param pb [String] path to playbook
    # @return [String] output
    alias :run :playbook

    # Exception to represent Playbook failures
    class Exception < RuntimeError; end
  end
end