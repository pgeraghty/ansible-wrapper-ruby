module Ansible
  describe Playbook do
    before do
      Ansible::ENV['ANSIBLE_HOST_KEY_CHECKING'] = 'False'
    end

    it 'can execute a basic Ansible Playbook command on localhost' do
      expect(Playbook.run '-i localhost, spec/mock_playbook.yml --list-hosts').to match /localhost/
    end

    it 'can execute a basic Ansible Playbook' do
      expect(Playbook.run '-i localhost, spec/mock_playbook.yml').to match /TASK(.?) \[Test task\]/
    end

    it 'can stream the output from execution of an Ansible Playbook' do
      cmd = '-i localhost, spec/mock_playbook.yml'

      expect { |b| Playbook.stream cmd, &b }.to yield_control
      expect(Playbook.stream(cmd) { |l| next }).to be_a Integer
      expect(Playbook.stream(cmd) { |l| break l if l[/PLAY \[Testing Playbook\]/] }).to match /Testing Playbook/
    end

    it 'defaults to standard output when streaming an Ansible Playbook if no block is given' do
      cmd = '-i localhost, spec/mock_playbook.yml'

      expect(Playbook.stream cmd).to be_a Integer
    end
  end
end