require 'spec_helper'

describe Ansible do
  it 'has a version number' do
    expect(Ansible::VERSION).not_to be nil
  end
end