require 'json'
require 'net/http'

module Spectator
  # Helper for HTTP requests
  class Http
    # Create a new instance using the given registry
    # to record stats for the requests performed
    def initialize(registry)
      @registry = registry
    end

    # Send a JSON payload to a given endpoing
    def post_json(endpoint, payload)
      s = payload.to_json
      uri = URI(endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      req.body = s
      begin
        res = http.request(req)
      rescue StandardError => e
        Spectator.logger.info("Cause #{e.cause} - msg=#{e.message}")
        return 400
      end

      res.value
    end
  end
end
