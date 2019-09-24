require 'ansible/version'
require 'ansible/ad_hoc'
require 'ansible/playbook'
require 'ansible/output'

module Ansible
  include Ansible::Config
  include Ansible::Methods
  include Ansible::PlaybookMethods

  extend self

  def enable_shortcuts!
    require 'ansible/shortcuts'
  end
end
