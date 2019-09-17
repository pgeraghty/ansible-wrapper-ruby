require 'spec_helper'

describe Ansible do
  it 'has a version number' do
    expect(Ansible::VERSION).not_to be nil
  end

  it 'can configure environment variables' do
    expect(Ansible.config.to_s '').not_to include 'SOME_ENV_VAR'

    expect {
      Ansible.configure { |config| config.env['SOME_ENV_VAR'] = 'False' }
    }.to change { Ansible.config.env['SOME_ENV_VAR'] }.from(nil).to('False')

    expect(Ansible.config.to_s '').to include('SOME_ENV_VAR=False')
  end

  it 'can run via shortcut methods when enabled' do
    Ansible.enable_shortcuts!
    disable_host_key_checking

    cmd = '-i localhost, spec/mock_playbook.yml'
    expect(A << cmd).to be_a Integer
    expect(A['all -i localhost, --list-hosts']).to match /localhost/
  end

  it 'can be included' do
    module Nodes
      include Ansible

      extend self

      def install!(ip)
        stream ['-i', ip, 'spec/mock_playbook.yml']*' '
      end
    end

    expect(Nodes.install! 'localhost,').to be_a Integer
  end
end