require 'spec_helper'

module Ansible
  describe Playbook do
    before(:all) do
      disable_host_key_checking
    end

    describe '.run' do
      it 'can execute a basic Ansible Playbook command on localhost' do
        expect(Playbook.run '-i localhost, spec/fixtures/mock_playbook.yml --list-hosts').to match /localhost/
      end

      before { suppress_output }
      it 'can execute a basic Ansible Playbook' do
        expect(Playbook.run '-i localhost, spec/fixtures/mock_playbook.yml').to match /TASK(.?) \[Test task\]/
      end
    end

    describe '.stream' do
      it 'can stream the output from execution of an Ansible Playbook' do
        cmd = '-i localhost, spec/fixtures/mock_playbook.yml'

        expect { |b| Playbook.stream cmd, &b }.to yield_control
        expect(Playbook.stream(cmd) { |l| next }).to be_a Integer
        expect(Playbook.stream(cmd) { |l| break l if l[/PLAY \[Testing Playbook\]/] }).to match /Testing Playbook/
      end

      it 'raises an error for a non-existent playbook' do
        expect { Playbook.stream('-i localhost, file_not_found.yml --list-hosts') { |l| next } }.to(
          raise_exception(Playbook::Exception, /could not be found/))
      end

      # TODO add this for Ad-Hoc
      it 'raises an error upon a fatal outcome (unreachable node)' do
        expect { Playbook.stream('-i localhost, spec/fixtures/fail_playbook.yml') { |l| next } }.to(
          raise_exception(Playbook::Exception, (/FAILED/ && /fatal/))) #  && /UNREACHABLE/
      end

      pending 'test ignore_failures is skipped' do
        fail
      end

      it 'defaults to standard output when streaming an Ansible Playbook if no block is given' do
        expect { Playbook.stream '-i localhost, spec/fixtures/mock_playbook.yml' }.to output(/Test task/).to_stdout
      end

      it 'returns a warning as part of the output when the inventory does not exist' do
        # TODO should probably raise an error for this behaviour (perhaps switch to pending)
        expect { Playbook.stream '-i localhost spec/fixtures/mock_playbook.yml' }.to output(/Unable to parse|Host file not found/).to_stdout
      end
    end
  end
end