[![Build Status](https://travis-ci.org/Netflix/spectator-rb.svg?branch=master)](https://travis-ci.org/Netflix/spectator-rb) 
# Netflix-Spectator-rb

> :warning: Experimental

Simple library for instrumenting code to record dimensional time series.

## Description

This implements a basic [Spectator](https://github.com/Netflix/spectator)
library for instrumenting ruby applications, sending metrics to an Atlas
aggregator service.

## Instrumenting Code

```ruby
require 'spectator'

class Response
  attr_accessor :status, :size

  def initialize(status, size)
    @status = status
    @size = size
  end
end

class Request
  attr_reader :country

  def initialize(country)
    @country = country
  end
end

class ExampleServer
  def initialize(registry)
    @registry = registry
    @req_count_id = registry.new_id('server.requestCount')
    @req_latency = registry.timer('server.requestLatency')
    @resp_sizes = registry.distribution_summary('server.responseSizes')
  end

  def expensive_computation(request)
    # ...
  end

  def handle_request(request)
    start = @registry.clock.monotonic_time

    # initialize response
    response = Response.new(200, 64)

    # Update the counter id with dimensions based on the request. The
    # counter will then be looked up in the registry which should be
    # fairly cheap, such as lookup of id object in a map
    # However, it is more expensive than having a local variable set
    # to the counter.
    cnt_id = @req_count_id.with_tag(:country, request.country)
                          .with_tag(:status, response.status.to_s)
    @registry.counter_with_id(cnt_id).increment

    # ...
    @req_latency.record(@registry.clock.monotonic_time - start)
    @resp_sizes.record(response.size)

    # timers can also time a given block
    # this is equivalent to:
    #  start = @registry.clock.monotonic_time
    #  expensive_computation(request)
    #  @registry.timer('server.computeTime').record(@registry.clock.monotonic_time - start)
    @registry.timer('server.computeTime').time { expensive_computation(request) }
    # ...
  end
end

config = {
  common_tags: { :'nf.app' => 'foo' },
  frequency: 0.5,
  uri: 'http://localhost:8080/api/v4/publish'
}

registry = Spectator::Registry.new(config)
registry.start

server = ExampleServer.new(registry)

# ...
# process some requests
requests = [Request.new('us'), Request.new('ar'), Request.new('ar')]
requests.each { |req| server.handle_request(req) }
sleep(2)

registry.stop
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spectator-rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spectator-rb

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Netflix/spectator-rb.
