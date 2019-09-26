require 'ansible/config'
require 'json'

module Ansible
  # Ansible Ad-Hoc methods
  module Methods
    # executable that runs Ansible Ad-Hoc commands
    BIN = 'ansible'

    # Run an Ad-Hoc Ansible command
    # @param cmd [String] the Ansible command to execute
    # @return [String] the output
    # @example Run a simple shell command with an inline inventory that only contains localhost
    #   one_off 'all -c local -a "echo hello"'
    def one_off(cmd)
      # TODO if debug then puts w/ colour
      `#{config.to_s "#{BIN} #{cmd}"}`
    end
    alias :[] :one_off

    # Ask Ansible to list hosts
    # @param cmd [String] the Ansible command to execute
    # @return [String] the output
    # @example List hosts with an inline inventory that only contains localhost
    #   list_hosts 'all -i localhost,'
    def list_hosts(cmd)
      output = one_off("#{cmd} --list-hosts").gsub!(/\s+hosts.*:\n/, '').strip
      output.split("\n").map(&:strip)
    end

    # Fetches host variables via Ansible's debug module
    # @param host [String] the +<host-pattern>+ for target host(s)
    # @param inv [String] the inventory host path or comma-separated host list
    # @param filter [String] the variable filter
    # @return [Hash] the variables pertaining to the host
    # @example List variables for localhost
    #   parse_host_vars 'localhost', 'localhost,'
    def parse_host_vars(host, inv, filter = 'hostvars[inventory_hostname]')
      cmd = "all -m debug -a 'var=#{filter}' -i #{inv} -l #{host}"
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

  # Provides static access to Ad-Hoc methods
  module AdHoc
    include Config
    include Methods

    extend self

    # Run an Ad-Hoc Ansible command
    # @see Methods#one_off
    # @param cmd [String] the Ansible command to execute
    # @return [String] the output
    # @since 0.2.1
    alias :run :one_off
  end
end