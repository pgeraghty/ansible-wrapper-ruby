require 'pty'

# Wrapper for PTY pseudo-terminal
module Ansible::SafePty
  # Spawns process for command
  # @param command [String] command
  # @return [Integer] exit status
  def self.spawn(command)

    PTY.spawn(command) do |r,w,p|
      begin
        yield r,w,p if block_given?
      rescue Errno::EIO
        nil # ignore Errno::EIO: Input/output error @ io_fillbuf
      ensure
        Process.wait p
      end
    end

    $?.exitstatus
  end
end