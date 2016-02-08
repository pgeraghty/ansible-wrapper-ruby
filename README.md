# Ansible Wrapper

[![Gem Version](https://badge.fury.io/rb/ansible-wrapper.svg)](http://badge.fury.io/rb/ansible-wrapper)
[![Build Status](https://travis-ci.org/pgeraghty/ansible-wrapper-ruby.svg?branch=master)](https://travis-ci.org/pgeraghty/ansible-wrapper-ruby)
[![Coverage Status](https://coveralls.io/repos/pgeraghty/ansible-wrapper-ruby/badge.svg?branch=master&service=github)](https://coveralls.io/github/pgeraghty/ansible-wrapper-ruby?branch=master)
[![Code Climate](https://codeclimate.com/github/pgeraghty/ansible-wrapper-ruby/badges/gpa.svg)](https://codeclimate.com/github/pgeraghty/ansible-wrapper-ruby)

#### A lightweight Ruby wrapper around Ansible that allows for ad-hoc commands and playbook execution. The primary purpose is to support easy streaming output.

## Installation

Ensure [Ansible](http://docs.ansible.com/intro_getting_started.html) is installed and available to shell commands i.e. in PATH.

Add this line to your application's Gemfile:

```ruby
gem 'ansible-wrapper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ansible-wrapper

## Usage

### Ad-hoc commands

```ruby
Ansible::AdHoc.run 'all -i localhost, --list-hosts'
```

```ruby
Ansible::AdHoc.run 'all -m shell -a "echo Test" -i localhost,'
```

### Playbooks

```ruby
Ansible::Playbook.run '-i localhost, spec/mock_playbook.yml'
```

```ruby
Ansible::Playbook.stream('-i localhost, spec/mock_playbook.yml') # defaults to standard output
```

```ruby
Ansible::Playbook.stream('-i localhost, spec/mock_playbook.yml') { |line_of_output| puts line_of_output }
```

### Shortcuts

To enable shortcuts:

```ruby
Ansible.enable_shortcuts!
```

You can then access Ansible via the `A` alias and use the following syntax:

```ruby
A['all -i localhost, --list-hosts'] # alias for Ansible::AdHoc.run
```

```ruby
A << '-i localhost, spec/mock_playbook.yml' # alias for Ansible::Playbook.stream
```

## Coming Soon

* Streaming output example using Sinatra

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pgeraghty/ansible-wrapper-ruby.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

