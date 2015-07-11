require 'ansible/version'
require 'ansible/ad_hoc'
require 'ansible/playbook'

module Ansible
  extend self
  ENV = {}

  def env_string
    ENV.map { |a| a*'=' }*' '
  end
end
