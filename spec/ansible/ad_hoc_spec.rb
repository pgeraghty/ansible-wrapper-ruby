require 'spec_helper'

module Ansible
  describe AdHoc do
    before do
      disable_host_key_checking
    end

    it 'can execute a basic ad-hoc Ansible command on localhost' do
      expect(AdHoc.run 'all -i localhost, --list-hosts').to match /localhost/
    end
  end
end
