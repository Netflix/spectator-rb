# frozen_string_literal: true

require_relative 'atomic_number'
require_relative 'measure'

module Spectator
  # A counter is used to measure the rate at which an event is occurring
  class Counter
    # Initialize a new instance setting its id, and starting the
    # count at 0
    def initialize(id)
      @id = id
      @count = AtomicNumber.new(0)
    end

    # Increment the counter by delta
    def increment(delta = 1)
      @count.add_and_get(delta)
    end

    # Get the current count as a list of Measure and reset the count to 0
    def measure
      cnt = @count.get_and_set(0)
      if cnt.positive?
        [Measure.new(@id.with_default_stat('count'), cnt)]
      else
        []
      end
    end

    # Read the current count. Calls to measure will reset it
    def count
      @count.get
    end

    # Get a string representation for debugging purposes
    def to_s
      "Counter{id=#{@id}, count=#{@count.get}}"
    end
  end
end
