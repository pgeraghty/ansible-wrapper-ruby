module Ansible
  describe Playbook do
    it 'can execute a basic Ansible Playbook command on localhost' do
      expect(Playbook.run '-i localhost, spec/mock_playbook.yml --list-hosts', skip_host_key_checking: true).to match /localhost/
    end

    it 'can execute a basic Ansible Playbook' do
      expect(Playbook.run '-i localhost, spec/mock_playbook.yml', skip_host_key_checking: true).to match /TASK: \[Test task\]/
    end

    it 'can stream the output from execution of an Ansible Playbook' do
      cmd = '-i localhost, spec/mock_playbook.yml'

      expect { |b| Playbook.stream cmd, skip_host_key_checking: true, &b }.to yield_control
      expect(Playbook.stream(cmd, skip_host_key_checking: true) { |l| next }).to be_a Fixnum
      expect(Playbook.stream(cmd, skip_host_key_checking: true) { |l| break l if l[/PLAY \[Testing Playbook\]/] }).to match /Testing Playbook/
    end

    it 'defaults to standard output when streaming an Ansible Playbook if no block is given' do
      cmd = '-i localhost, spec/mock_playbook.yml'

      expect(Playbook.stream cmd, skip_host_key_checking: true).to be_a Fixnum
    end
  end
end