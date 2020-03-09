# Changelog

## 0.3.0

### Breaking changes
`Playbook.stream` has been refactored to include a new `raise_on_failure` parameter. 
This is part of a change in behaviour for this method to no longer raise exceptions by default 
and stream the entire Playbook execution.

To previous behaviour can be obtained by passing `raise_on_failure: :during` 
to the `stream`method i.e.

```ruby
Playbook.stream "some_playbook.yml", raise_on_failure: :during
```

Alternatively, if you'd still like to raise exception for failures, but only after output has finished streaming, you can use:
```ruby
Playbook.stream "some_playbook.yml", raise_on_failure: :after
```

In addition to the breaking changes above,`Playbook.stream` now handles tasks that 
are skipped according to Ansible's output. 
This should include tasks which have `ignore_errors` set.