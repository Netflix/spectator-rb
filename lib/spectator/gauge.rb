# frozen_string_literal: true

require 'spectator/atomic_number'
require 'spectator/measure'

module Spectator
  # A meter with a single value that can only be sampled at a point in time.
  # A typical example is a queue size.
  class Gauge
    # Initialize a new instance of a Gauge with the given id
    def initialize(id)
      @id = id
      @value = AtomicNumber.new(Float::NAN)
    end

    # Get the current value
    def get
      @value.get
    end

    # Set the current value to the number specified
    def set(value)
      @value.set(value)
    end

    # Get the current value, and reset it
    def measure
      [Measure.new(@id.with_stat('gauge'), @value.get_and_set(Float::NAN))]
    end

    # A string representation of this gauge, useful for debugging purposes
    def to_s
      "Gauge{id=#{@id}, value=#{@value.get}}"
    end
  end
end
