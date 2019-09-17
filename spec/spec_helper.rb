$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'coveralls'
Coveralls.wear!

require 'ansible-wrapper'

def disable_host_key_checking
  Ansible.configure { |config| config.env['ANSIBLE_HOST_KEY_CHECKING'] = 'False' }
end