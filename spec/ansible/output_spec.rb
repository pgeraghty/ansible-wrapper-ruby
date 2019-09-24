require 'spec_helper'

module Ansible
  module Output
    describe '.to_html' do
      context 'can convert ANSI escape sequence colours to HTML styles' do
        it 'ignores text without escape sequences' do
          output = "Plain\nText\nHere"
          expect(Output.to_html output).to eq output
        end

        it 'opens a span tag with style when the appropriate sequence is detected' do
          output = "\e[31mRed"
          expect(Output.to_html output).to match /<span style="color: red;">Red/
        end

        it 'ignores unstyled text before an escape sequence' do
          output = "Default \e[31mRed"
          expect(Output.to_html output).to match /Default <span style="color: red;">Red/
        end

        it 'closes a span tag when the appropriate sequence is detected' do
          output = "\e[32mGreen\e[0m"
          expect(Output.to_html output).to match /<span style="color: green;">Green<\/span>/
        end

        it 'ignores unstyled text after an escape sequence' do
          output = "\e[90mGrey\e[0mDefault"
          expect(Output.to_html output).to match /<span style="color: grey;">Grey<\/span>Default/
        end

        it 'ignores newlines' do
          output = "\e[32mGreen\e[0m\n"
          expect(Output.to_html output).to match /<span style="color: green;">Green<\/span>\n/
        end

        it 'ignores tags left open' do
          output = "\e[0m\n\e[0;32mGreen\e[0m\n\e[0;34mBlue"
          expect(Output.to_html output).to match /<\/span>\n<span style="color: green;">Green<\/span>\n<span style="color: blue;">Blue/
        end

        it 'handles bold output alongside colour with dual styles in a single tag' do
          output = "\e[1;35mBold Magenta\e[0m"
          expect(Output.to_html output).to eq "<span style=\"font-weight: bold; color: magenta;\">Bold Magenta</span>"
        end

        it 'scrubs unsupported escape sequences' do
          output = "\e[38;5;118mBright Green - unsupported\e[0m"
          expect(Output.to_html output).to eq "<span>Bright Green - unsupported</span>"
        end

        it 'handles some malformed cases (missing semicolon)' do
          output = "\e[132mBright Green"
          expect(Output.to_html output).to eq '<span style="font-weight: bold; color: green;">Bright Green'
        end

        # This code may be entirely unreachable as regexp appears to be very specific
        it 'handles situations where no style attribute should be added to the tag' do
          output = "\e[0;99Nothing\e[0m"

          s = instance_double("StringScanner")
          allow(s).to receive(:eos?).and_return(false, true)
          allow(s).to receive(:scan).and_return(true, '')
          allow(s).to receive(:[]).and_return(nil, nil)

          class_double("StringScanner", new: s).as_stubbed_const

          expect(Output.to_html output).to match /<span>/
        end

        it 'correctly formats output of a streamed playbook' do
         output = ''
         Ansible.stream(['-i', 'localhost,', 'spec/fixtures/mock_playbook.yml']*' ') do |line|
           output << Ansible::Output.to_html(line)
         end

          expect(output).to match /<span style="color: green;">ok=1/
        end

        context 'for a non-existent playbook' do
          output = ''

          it 'raises an error' do
            expect {
              Ansible.stream(['-i', 'localhost,', 'does_not_exist.yml']*' ') do |line|
                output << Ansible::Output.to_html(line)
              end
            }.to raise_error(Ansible::Playbook::Exception, /ERROR! the playbook: does_not_exist.yml could not be found/)
          end

          it 'outputs an error message' do
            expect(output).to match /<span style="color: red;">ERROR! the playbook: does_not_exist.yml could not be found<\/span>/
          end
        end
      end
    end
  end
end