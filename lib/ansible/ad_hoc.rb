module Ansible::Methods
  BIN = 'ansible'

  def one_off cmd
    `#{config.to_s "#{BIN} #{cmd}"}`
  end
  alias :[] :one_off

  # this solution should work for Ansible pre-2.0 as well as 2.0+
  def list_hosts cmd
    one_off("#{cmd} --list-hosts").scan(IP_OR_HOSTNAME).map { |ip| ip.first.strip }
  end

  def parse_host_vars(host, inv_file, filter = 'hostvars[inventory_hostname]')
    hostvars_filter = filter
    cmd = "all -m debug -a 'var=#{hostvars_filter}' -i #{inv_file} -l #{host} --one-line"
    hostvars = JSON.parse(self[cmd].split(/>>|=>/).last)

    if Gem::Version.new(Ansible::Config::VERSION) >= Gem::Version.new('2.0')
      hostvars[hostvars_filter]
    else
      hostvars['var'][hostvars_filter]
    end
  end
end

module Ansible
  module AdHoc
    include Ansible::Config
    include Ansible::Methods

    extend self
    alias :run :one_off
  end
end