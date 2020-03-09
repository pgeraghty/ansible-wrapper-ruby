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

      context 'for a non-existent playbook' do
        it 'raises an error when requested' do
          expect {
            Playbook.stream('-i localhost, file_not_found.yml --list-hosts',
                            raise_on_failure: :during) { next }
          }.to raise_exception(Playbook::Exception, /could not be found/)
        end

        it 'provides output otherwise' do
          expect {
            Playbook.stream('-i localhost, file_not_found.yml --list-hosts')
          }.to output(/could not be found/).to_stdout
        end
      end

      # TODO add this for Ad-Hoc
      context 'upon a fatal outcome (unreachable node)' do
        it 'raises an error when requested and ceases output' do
          output = ""

          expect {
            Playbook.stream('-i localhost, spec/fixtures/fail_playbook.yml',
                            raise_on_failure: :during) { |line| output << line }
          }.to raise_exception(Playbook::Exception, (/FAILED/ && /fatal/)) #  && /UNREACHABLE/

          expect(output).to_not include('PLAY RECAP')
        end

        it 'provides output otherwise' do #  { |l| next }
          expect {
            Playbook.stream('-i localhost, spec/fixtures/fail_playbook.yml')
          }.to output(/PLAY RECAP/).to_stdout
        end
      end

      context 'continues to stream output despite failures' do
        it 'by default' do
          expect {
            Playbook.stream('-i localhost, spec/fixtures/fail_playbook.yml')
          }.to output(/PLAY RECAP/).to_stdout
        end

        it 'when raise_on_failure is set to :after' do
          expect {
            Playbook.stream('-i localhost, spec/fixtures/fail_playbook.yml', raise_on_failure: :after)
          }.to raise_exception(Playbook::Exception).and output(/PLAY RECAP/).to_stdout
        end

        it 'but not when raise_on_failure is :during' do
          output = ""

          expect {
            Playbook.stream('-i localhost, spec/fixtures/fail_playbook.yml',
                            raise_on_failure: :during) { |line| output << line }
          }.to raise_exception(Playbook::Exception)

          expect(output).to_not include('PLAY RECAP')
        end
      end

      it 'continues to stream output despite failures when requested' do
        expect {
          Playbook.stream('-i localhost, spec/fixtures/fail_playbook.yml', raise_on_failure: :after)
        }.to raise_exception(Playbook::Exception).and output(/PLAY RECAP/).to_stdout
      end

      context 'where ignore_errors is set for tasks' do
        it 'skips a single failure when ignored' do
          expect {
            Playbook.stream('-i localhost, spec/fixtures/ignored_errors_playbook.yml', raise_on_failure: :during) { |l| next }
          }.not_to raise_exception
        end

        it 'skips multiple failures when they are ignored' do
          expect {
            Playbook.stream('-i localhost, spec/fixtures/ignored_errors_playbook.yml', raise_on_failure: :during) { |l| next }
          }.not_to raise_exception
        end

        it 'skips failures when they are ignored, but still reports later failures' do
          expect {
            Playbook.stream('-i localhost, spec/fixtures/ignored_error_then_failure_playbook.yml',
                            raise_on_failure: :during) { |l| next }
          }.to raise_exception(Playbook::Exception)
        end

        it 'skips failures when they are ignored, but still reports earlier failures' do
          expect {
            Playbook.stream('-i localhost, spec/fixtures/failure_then_ignored_error_playbook.yml',
                            raise_on_failure: :during) { |l| next }
          }.to raise_exception(Playbook::Exception)
        end
      end

      it 'defaults to standard output when streaming an Ansible Playbook if no block is given' do
        expect {
          Playbook.stream '-i localhost, spec/fixtures/mock_playbook.yml'
        }.to output(/Test task/).to_stdout
      end

      it 'returns a warning as part of the output when the inventory does not exist' do
        # TODO should probably raise an error for this behaviour (perhaps switch to pending)
        expect { Playbook.stream '-i localhost spec/fixtures/mock_playbook.yml' }.to output(/Unable to parse|Host file not found/).to_stdout
      end
    end
  end
end