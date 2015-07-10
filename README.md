# Ansible Wrapper

A lightweight Ruby wrapper around Ansible that allows for ad-hoc commands and playbook execution. The primary purpose is to support easy streaming output.

## Installation

Ensure Ansible is installed and available to shell commands i.e. in PATH.

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
Ansible::AdHoc.run 'all -m shell -a "echo Test" -i localhost, '
```

### Playbooks

```ruby
Ansible::Playbook.run '-i localhost, spec/mock_playbook.yml'
```

```ruby
Ansible::Playbook.stream('-i localhost, spec/mock_playbook.yml') { |line_of_output| puts line_of_output }
```

## Coming Soon

* Streaming output example using Sinatra
* Optional shortcuts

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ansible-wrapper.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

