module Ansible
  # Ansible configuration
  module Config
    PATH = 'lib/ansible/'
    # IP_OR_HOSTNAME = /((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3})$|^((([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9]))\n/
    SKIP_HOSTVARS = %w(ansible_version inventory_dir inventory_file inventory_hostname inventory_hostname_short group_names groups omit playbook_dir)
    VERSION = `ansible --version`.split("\n").first.split.last rescue nil # nil when Ansible not installed

    # Default configuration options
    DefaultConfig = Struct.new(:env, :extra_vars, :params) do
      # @!attribute env
      #   @return [Hash] environment variables
      # @!attribute params
      #   @return [Hash] parameters
      # @!attribute extra_vars
      #   @return [Hash] extra variables to pass to Ansible

      def initialize
        self.env = {
          'ANSIBLE_FORCE_COLOR' => 'True',
          'ANSIBLE_HOST_KEY_CHECKING' => 'False'
        }

        self.extra_vars = {
          # skip creation of .retry files
          'retry_files_enabled' => 'False'
        }
        # TODO support --ssh-common-args, --ssh-extra-args
        # e.g. ansible-playbook --ssh-common-args="-o ServerAliveInterval=60" -i inventory install.yml

        self.params = {
          debug: false
        }
      end

      # Pass additional options to Ansible
      # NB: --extra-vars can also accept JSON string, see http://stackoverflow.com/questions/25617273/pass-array-in-extra-vars-ansible
      # @return [String] command-line options
      def options
        x = extra_vars.each_with_object('--extra-vars=\'') { |kv, a| a << "#{kv.first}=\"#{kv.last}\" " }.strip+'\'' if extra_vars unless extra_vars.empty?
        # can test with configure { |config| config.extra_vars.clear }

        [x, '--ssh-extra-args=\'-o UserKnownHostsFile=/dev/null\'']*' '
      end

      # Output configuration as a string for the command-line
      # @param cmd [String] command to be appended to the command-line produced
      # @return [Config, DefaultConfig] the configuration
      def to_s(cmd)
        entire_cmd = [env.each_with_object([]) { |kv, a| a << kv*'=' } * ' ', cmd, options]*' '
        puts entire_cmd if params[:debug]
        entire_cmd
      end
    end

    # Create and yield configuration
    # @return [Config, DefaultConfig] the configuration
    def configure
      @config ||= DefaultConfig.new
      yield(@config) if block_given?

      # allow chaining if block given
      block_given? ? self : @config
    end

    # accessor for config
    # @return [DefaultConfig] the configuration
    def config
      @config || configure
    end
  end
end