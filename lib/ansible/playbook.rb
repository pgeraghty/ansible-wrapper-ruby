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
    # @param raise_on_failure [Symbol] Specifies if streaming should raise an exception when a Playbook failure occurs.
    #   Defaults to +:false+, can also be +:during+ to raise as soon as an error occurs or +:after+ to allow all output to stream first.
    # @raise [Playbook::Exception] if +raise_on_failure+ is truthy
    # @return [Integer] exit status
    def stream(pb, raise_on_failure: false)
      cmd = config.to_s("#{BIN} #{pb}")
      error_at_line = {}

      pid = SafePty.spawn cmd do |r,_,_| # add -vvvv here for verbose
        line_num = 0

        until r.eof? do
          line = r.gets
          line_num += 1

          block_given? ? yield(line) : puts(line)

          # track errors in output by line
          if raise_on_failure
            case line
              when /(fatal|failed): \[/ then error_at_line[line_num] ||= "FAILED: #{line}"
              when /ERROR!/, /FAILED!/ then error_at_line[line_num] ||= "ERROR: #{line}"
              # allow errors on previous line to be ignored
              when /...ignoring/ then error_at_line.delete(line_num-1)
            end

            if raise_on_failure == :during
              # trigger failure unless it was ignored
              fatal_unskipped_error = error_at_line[line_num-1]
              raise Playbook::Exception.new(fatal_unskipped_error) if fatal_unskipped_error
            end
          end
        end
      end

      if raise_on_failure
        # at this point, all output has been streamed
        fatal_unskipped_error = error_at_line.first
        raise Playbook::Exception.new(fatal_unskipped_error.last) if fatal_unskipped_error
      end

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
