require 'spec_helper'

describe Ansible do
  it 'has a version number' do
    expect(Ansible::VERSION).not_to be nil
  end

  it 'can run via shortcut methods when enabled' do
    Ansible.enable_shortcuts!
    Ansible::ENV['ANSIBLE_HOST_KEY_CHECKING'] = 'False'

    cmd = '-i localhost, spec/mock_playbook.yml'
    expect(A << cmd).to be_a Integer
    expect(A['all -i localhost, --list-hosts']).to match /localhost/
  end
end