require 'strscan'
require 'erb'

module Ansible::Output
  COLOR = {
  '1' => 'font-weight: bold',
  '30' => 'color: black',
  '31' => 'color: red',
  '32' => 'color: green',
  '33' => 'color: yellow',
  '34' => 'color: blue',
  '35' => 'color: magenta',
  '36' => 'color: cyan',
  '37' => 'color: white',
  '90' => 'color: grey'
  }

  def self.to_html(line, stream='')
    s = StringScanner.new(ERB::Util.h line)
    while(!s.eos?)
      if s.scan(/\e\[0;(3[0-7]|90|1)m/)
        stream << %{<span style="#{COLOR[s[1]]};">}
      else
        if s.scan(/\e\[0m/)
          stream << %{</span>}
        else
          stream << s.scan(/./m)
        end
      end
    end


    stream
  end
end