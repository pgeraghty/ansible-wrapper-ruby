require 'ansible/version'
require 'ansible/ad_hoc'
require 'ansible/playbook'
require 'ansible/output'

# A lightweight Ruby wrapper around Ansible that allows for ad-hoc commands and playbook execution.
# The primary purpose is to support easy streaming output.
module Ansible
  include Ansible::Config
  include Ansible::Methods
  include Ansible::PlaybookMethods

  extend self

  # Enables shortcuts
  # @see ansible/shortcuts.rb
  def enable_shortcuts!
    require 'ansible/shortcuts'
  end
end
