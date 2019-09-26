module Ansible
  extend self

  # shortcut for executing an Ad-Hoc command
  # @param cmd [String] the command-line to pass
  # @see AdHoc#run
  def [](cmd)
    AdHoc.run cmd
  end

  # shortcut to run a Playbook, streaming the output
  # @param cmd [String] the command-line to pass
  # @see Playbook#stream
  def <<(cmd)
    Playbook.stream cmd
  end
end
A = Ansible unless defined?(A)