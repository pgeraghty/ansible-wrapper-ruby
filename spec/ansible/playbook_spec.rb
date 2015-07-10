module Ansible
  describe Playbook do
    it 'can execute a basic Ansible Playbook command on localhost' do
      expect(Playbook.run '-i localhost, spec/mock_playbook.yml --list-hosts').to match /localhost/
    end

    it 'can execute a basic Ansible Playbook' do
      expect(Playbook.run '-i localhost, spec/mock_playbook.yml').to match /TASK: \[Test task\]/
    end

    it 'can stream the output from execution of an Ansible Playbook' do
      cmd = '-i localhost, spec/mock_playbook.yml'

      expect { |b| Playbook.stream cmd, &b }.to yield_control
      expect(Playbook.stream(cmd) { |l| next }).to be_a Fixnum
      expect(Playbook.stream(cmd) { |l| break l if l[/PLAY \[Testing Playbook\]/] }).to match /Testing Playbook/
    end
  end
end