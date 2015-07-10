require 'pty'

module SafePty
  def self.spawn command, &block

    PTY.spawn(command) do |r,w,p|
      begin
        yield r,w,p
      rescue Errno::EIO
        # ignore Errno::EIO: Input/output error @ io_fillbuf
      ensure
        Process.wait p
      end
    end

    $?.exitstatus
  end
end