require 'ansible/config'
require 'json'

module Ansible
  module Methods
    BIN = 'ansible'

    def one_off cmd
      `#{config.to_s "#{BIN} #{cmd}"}`
    end
    alias :[] :one_off

    def list_hosts cmd
      output = one_off("#{cmd} --list-hosts").gsub!(/\s+hosts.*:\n/, '').strip
      output.split("\n").map(&:strip)
    end

    def parse_host_vars(host, inv_file, filter = 'hostvars[inventory_hostname]')
      cmd = "all -m debug -a 'var=#{filter}' -i #{inv_file} -l #{host}"
      json = self[cmd].split(/>>|=>/).last

      # remove any colour added to console output
      # TODO move to Output module as #bleach, perhaps use term-ansicolor
      # possibly replace regexp with /\e\[(?:(?:[349]|10)[0-7]|[0-9]|[34]8;5;\d{1,3})?m/
      # possibly use ANSIBLE_NOCOLOR? or --nocolor
      json = json.strip.chomp.gsub(/\e\[[0-1][;]?(3[0-7]|90|1)?m/, '')

      hostvars = JSON.parse(json)

      hostvars[filter]
    end
  end

  module AdHoc
    include Ansible::Config
    include Ansible::Methods

    extend self
    alias :run :one_off
  end
end