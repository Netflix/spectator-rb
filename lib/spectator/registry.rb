require 'spectator/clock'
require 'spectator/counter'
require 'spectator/distribution_summary'
require 'spectator/gauge'
require 'spectator/http'
require 'spectator/meter_id'
require 'spectator/timer'

module Spectator
  # Registry to manage a set of meters
  class Registry
    attr_reader :config, :clock, :publisher, :common_tags

    # Initialize the registry using the given config, and clock
    # The default clock is the SystemClock
    # The config is a Hash which should include:
    #  :common_tags as a hash with tags that will be added to all metrics
    #  :frequency the interval at which metrics will be sent to an
    #  aggregator service, expressed in seconds
    #  :uri the endpoint for the aggregator service
    def initialize(config, clock = SystemClock.new)
      @config = config
      @clock = clock
      @meters = {}
      @common_tags = to_symbols(config[:common_tags]) || {}
      @lock = Mutex.new
      @publisher = Publisher.new(self)
    end

    # Create a new MeterId with the given name, and optional tags
    def new_id(name, tags = nil)
      MeterId.new(name, tags)
    end

    # Create or get a Counter with the given id
    def counter_with_id(id)
      new_meter(id) { |meter_id| Counter.new(meter_id) }
    end

    # Create or get a Gauge with the given id
    def gauge_with_id(id)
      new_meter(id) { |meter_id| Gauge.new(meter_id) }
    end

    # Create or get a DistributionSummary with the given id
    def distribution_summary_with_id(id)
      new_meter(id) { |meter_id| DistributionSummary.new(meter_id) }
    end

    # Create or get a Timer with the given id
    def timer_with_id(id)
      new_meter(id) { |meter_id| Timer.new(meter_id) }
    end

    # Create or get a Counter with the given name, and optional tags
    def counter(name, tags = nil)
      counter_with_id(MeterId.new(name, tags))
    end

    # Create or get a Gauge with the given name, and optional tags
    def gauge(name, tags = nil)
      gauge_with_id(MeterId.new(name, tags))
    end

    # Create or get a DistributionSummary with the given name, and optional tags
    def distribution_summary(name, tags = nil)
      distribution_summary_with_id(MeterId.new(name, tags))
    end

    # Create or get a Timer with the given name, and optional tags
    def timer(name, tags = nil)
      timer_with_id(MeterId.new(name, tags))
    end

    # Get the list of measurements from all registered meters
    def measurements
      @lock.synchronize do
        @meters.values.flat_map(&:measure)
      end
    end

    # Start publishing measurements to the aggregator service
    def start
      @publisher.start
    end

    # Stop publishing measurements
    def stop
      @publisher.stop
    end

    private

    def to_symbols(tags)
      return nil if tags.nil?

      symbolic_tags = {}
      tags.each { |k, v| symbolic_tags[k.to_sym] = v.to_sym }
      symbolic_tags
    end

    def new_meter(meter_id)
      @lock.synchronize do
        meter = @meters[meter_id.key]
        if meter.nil?
          meter = yield(meter_id)
          @meters[meter_id.key] = meter
        end
        meter
      end
    end
  end

  # Internal class used to publish measurements to an aggregator service
  class Publisher
    def initialize(registry)
      @registry = registry
      @started = false
      @should_stop = false
      @frequency = registry.config[:frequency] || 5
      @http = Http.new(registry)
    end

    def should_start?
      if @started
        Spectator.logger.info('Ignoring start request. ' \
          'Spectator registry already started')
        return false
      end

      @started = true
      uri = @registry.config[:uri]
      if uri.nil? || uri.empty?
        Spectator.logger.info('Ignoring start request since Spectator ' \
                                  'registry has no valid uri')
        return false
      end

      true
    end

    # Start publishing if the config is acceptable:
    #  uri is non-nil or empty
    def start
      return unless should_start?

      Spectator.logger.info 'Starting Spectator registry'

      @should_stop = false
      @publish_thread = Thread.new do
        publish
      end
    end

    # Stop publishing measurements
    def stop
      unless @started
        Spectator.logger.info('Attemping to stop Spectator ' \
          'without a previous call to start')
        return
      end

      @should_stop = true
      Spectator.logger.info('Stopping spectator')
      @publish_thread.kill if @publish_thread

      @started = false
      Spectator.logger.info('Sending last batch of metrics before exiting')
      send_metrics_now
    end

    ADD_OP = 0
    MAX_OP = 10
    UNKNOWN_OP = -1
    OPS = { count: ADD_OP,
            totalAmount: ADD_OP,
            totalTime: ADD_OP,
            totalOfSquares: ADD_OP,
            percentile: ADD_OP,
            max: MAX_OP,
            gauge: MAX_OP,
            activeTasks: MAX_OP,
            duration: MAX_OP }.freeze
    # Get the operation to be used for the given Measure
    # Gauges are aggregated using MAX_OP, counters with ADD_OP
    def op_for_measurement(measure)
      stat = measure.id.tags.fetch(:statistic, :unknown)
      OPS.fetch(stat, UNKNOWN_OP)
    end

    # Gauges are sent if they have a value
    # Counters if they have a number of increments greater than 0
    def should_send(measure)
      op = op_for_measurement(measure)
      return measure.value > 0 if op == ADD_OP
      return !measure.value.nan? if op == MAX_OP

      false
    end

    # Build a string table from the list of measurements
    # Unique words are identified, and assigned a number starting from 0 based
    # on their lexicographical order
    def build_string_table(measurements)
      common_tags = @registry.common_tags
      table = {}
      common_tags.each do |k, v|
        table[k] = 0
        table[v] = 0
      end
      table[:name] = 0
      measurements.each do |m|
        table[m.id.name] = 0
        m.id.tags.each do |k, v|
          table[k] = 0
          table[v] = 0
        end
      end
      keys = table.keys.sort
      keys.each_with_index do |str, index|
        table[str] = index
      end
      table
    end

    # Add a measurement to our payload table.
    # The serialization for a measurement is:
    #  - length of tags
    #  - indexes for the tags based on the string table
    #  - operation (add (0), max (10))
    #  - floating point value
    def append_measurement(payload, table, measure)
      op = op_for_measurement(measure)
      common_tags = @registry.common_tags
      tags = measure.id.tags
      len = tags.length + 1 + common_tags.length
      payload.push(len)
      common_tags.each do |k, v|
        payload.push(table[k])
        payload.push(table[v])
      end
      tags.each do |k, v|
        payload.push(table[k])
        payload.push(table[v])
      end
      payload.push(table[:name])
      payload.push(table[measure.id.name])
      payload.push(op)
      payload.push(measure.value)
    end

    # Generate a payload from the list of measurements
    # The payload is an array, with the number of elements in the string table
    # The string table, and measurements
    def payload_for_measurements(measurements)
      table = build_string_table(measurements)
      payload = []
      payload.push(table.length)
      strings = table.keys.sort
      payload.concat(strings)
      measurements.each { |m| append_measurement(payload, table, m) }
      payload
    end

    # Get a list of measurements that should be sent
    def registry_measurements
      @registry.measurements.select { |m| should_send(m) }
    end

    # Send the current measurements to our aggregator service
    def send_metrics_now
      ms = registry_measurements
      if ms.empty?
        Spectator.logger.debug 'No measurements to send'
      else
        payload = payload_for_measurements(ms)
        uri = @registry.config[:uri]
        Spectator.logger.info "Sending #{ms.length} measurements to #{uri}"
        @http.post_json(uri, payload)
      end
    end

    # Publish loop:
    #   send measurements to the aggregator endpoint ':uri',
    #   every ':frequency' seconds
    def publish
      clock = @registry.clock
      until @should_stop
        start = clock.wall_time
        Spectator.logger.info 'Publishing'
        send_metrics_now
        elapsed = clock.wall_time - start
        sleep @frequency - elapsed if elapsed < @frequency
      end
      Spectator.logger.info 'Stopping publishing thread'
    end
  end
end
