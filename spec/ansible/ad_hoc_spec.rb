require 'spec_helper'

module Ansible
  describe AdHoc do
    before(:all) do
      disable_host_key_checking
    end

    describe '.run' do
      it 'can execute a basic ad-hoc Ansible command on localhost' do
        expect(AdHoc.run 'all -i localhost, --list-hosts').to match /localhost/
      end
    end

    describe '.list_hosts' do
      it 'can list hosts for an inline inventory' do
        inline_inv = %w(localhost 99.99.99.99)
        cmd = "all -i #{inline_inv*','}, --list-hosts"

        expect(AdHoc.list_hosts cmd).to match inline_inv
      end
    end

    describe '.parse_host_vars' do
      it 'can parse and return default host vars' do
        host_vars = AdHoc.parse_host_vars 'all', 'localhost,'
        expect(host_vars['inventory_hostname']).to match 'localhost'
      end
    end
  end
end
