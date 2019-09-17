require 'sinatra'

require 'ansible-wrapper'

set server: 'thin'
set :environment, :production
set :bind, '0.0.0.0'
set :port, 4567

Process.setproctitle 'Ansible Streaming Example'


CONSOLE_OUTPUT_START = %{<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <style>
    body {
      background-color: #{background ||= 'black'}; color: #{color ||= 'white'};
    }
    .bold {
      font-weight: bold;
    }
    .black {
      color: black;
    }
    .red {
      color: red;
    }
    .green {
      color: green;
    }
    .yellow {
      color: yellow;
    }
    .blue {
      color: blue;
    }
    .magenta {
      color: magenta;
    }
    .cyan {
      color: cyan;
    }
    .white {
      color: white;
    }
    .grey {
      color: grey;
    }
  </style>
</head>
<body><pre><code>}

CONSOLE_OUTPUT_END = '</code></pre></body></html>'


get '/' do
  "Ansible #{Ansible::Config::VERSION}"
end

get '/streaming' do
  #content_type 'text/plain'
  stream do |out|
    out << CONSOLE_OUTPUT_START
    Ansible.stream ['-i', 'localhost,', File.expand_path('../../../spec/mock_playbook.yml', __FILE__)]*' ' do |line|
      Ansible::Output.to_html line, out
    end
    out << CONSOLE_OUTPUT_END
  end
end
