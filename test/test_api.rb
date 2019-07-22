# frozen_string_literal: true

# Simple example to verify the API is somewhat usable
#
# It is not executed automatically by rake
#
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

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
  end
end

config = {
  common_tags: { 'nf.app' => 'foo' },
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
