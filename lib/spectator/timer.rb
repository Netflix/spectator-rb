require 'spectator/atomic_number'
require 'spectator/clock'

module Spectator
  # The class Timer is intended to track a large number of
  # short running events. Example would be something like
  # an http request. Though "short running" is a bit subjective
  # the assumption is that it should be  under a minute.
  class Timer
    def initialize(id, clock = SystemClock.new)
      @id = id
      @clock = clock

      @count = AtomicNumber.new(0)
      @total_time = AtomicNumber.new(0)
      @total_sq = AtomicNumber.new(0)
      @max = AtomicNumber.new(Float::NAN)
    end

    # Update the statistics kept by this timer. If the amount of nanoseconds
    # passed is negative, the value will be ignored.
    def record(nanos)
      return if nanos.negative?

      @count.add_and_get(1)
      @total_time.add_and_get(nanos)
      @total_sq.add_and_get(nanos * nanos)
      @max.max(nanos)
    end

    # Record the time it takes to execute the given block
    #
    def time
      start = @clock.monotonic_time
      yield
      elapsed = @clock.monotonic_time - start
      record(elapsed)
    end

    # Get the number of events recorded
    def count
      @count.get
    end

    # Get the total time of events recorded in nanoseconds
    def total_time
      @total_time.get
    end

    # Measure this timer. It returns the count, totalTime in seconds,
    # max in seconds, and totalOfSquares (normalized) to seconds to seconds
    def measure
      total_seconds = @total_time.get_and_set(0) / 1e9
      max_seconds = @max.get_and_set(Float::NAN) / 1e9
      tot_sq_seconds = @total_sq.get_and_set(0) / 1e18

      cnt = Measure.new(@id.with_stat('count'), @count.get_and_set(0))
      tot = Measure.new(@id.with_stat('totalTime'), total_seconds)
      tot_sq = Measure.new(@id.with_stat('totalOfSquares'), tot_sq_seconds)
      mx = Measure.new(@id.with_stat('max'), max_seconds)

      [cnt, tot, tot_sq, mx]
    end
  end
end
