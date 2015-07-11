require 'spec_helper'

module Ansible
  describe AdHoc do
    it 'can execute a basic ad-hoc Ansible command on localhost' do
      expect(AdHoc.run 'all -i localhost, --list-hosts', skip_host_key_checking: true).to match /localhost/
    end
  end
end
