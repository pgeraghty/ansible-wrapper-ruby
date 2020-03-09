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

    # TODO add options for stream(pb, ignore_errors: true) & stream(pb, stop_on_error: true)
    # Stream execution of a playbook using PTY because otherwise output is buffered
    # @param pb [String] path to playbook
    # @return [Integer] exit status
    def stream(pb)
      cmd = config.to_s("#{BIN} #{pb}")
      error_at_line = {}

      pid = SafePty.spawn cmd do |r,_,_| # add -vvvv here for verbose
        line_num = 0

        until r.eof? do
          line = r.gets
          line_num += 1

          block_given? ? yield(line) : puts(line)

          # track errors in output by line
          # TODO allow configuration to override and trigger instant failure
          case line
            when /fatal: \[/ then error_at_line[line_num] ||= "FAILED: #{line}"
            when /ERROR!/, /FAILED!/ then error_at_line[line_num] ||= "ERROR: #{line}"
            # allow errors on previous line to be ignored
            when /...ignoring/ then error_at_line.delete(line_num-1)
          end
        end
      end

      fatal_unskipped_error = error_at_line.first
      raise Playbook::Exception.new(fatal_unskipped_error.last) if fatal_unskipped_error

      pid
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