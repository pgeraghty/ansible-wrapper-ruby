module Ansible
  extend self

  def [](cmd)
    AdHoc.run cmd
  end

  def <<(cmd)
    Playbook.stream cmd
  end
end
A = Ansible unless defined?(A)