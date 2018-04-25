module Spectator
  # A timing source that can be used to access the current time as an object,
  # and a high resolution monotonic time
  class SystemClock
    # A monotonically increasing number of nanoseconds. This is useful for
    # recording times, or benchmarking.
    # Note that this is not guaranteed to be steady.
    # In other words each tick of the underlying clock may not
    # be the same length (e.g. some seconds might be longer than others)
    # @return A monotonic number of nanoseconds
    def monotonic_time
      MonotonicTime.time_in_nanoseconds
    end

    # @return a time object for the current time
    def wall_time
      Time.now
    end
  end

  # A timing source useful in unit tests that can be used to mock the methods in
  # SystemClock
  class ManualClock
    attr_accessor :wall_time
    attr_accessor :monotonic_time

    # Get a new object using 2000-1-1 0:0:0 UTC as the default time,
    # and 0 nanoseconds as the number of nanos reported by monotonic_time
    def initialize(wall_init: Time.utc(2000, 'jan', 1, 0, 0, 0), mono_time: 0)
      @wall_time = wall_init
      @monotonic_time = mono_time
    end
  end

  # Gather a monotonically increasing number of nanoseconds.
  # If Process::CLOCK_MONOTONIC is available  we use that, otherwise we attempt
  # to use java.lang.System.nanoTime if running in jruby, and fallback
  # to the Time.now implementation
  module MonotonicTime
    module_function

    if defined? Process::CLOCK_MONOTONIC
      def time_in_nanoseconds
        Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
      end
    elsif (defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby') == 'jruby'
      def time_in_nanoseconds
        java.lang.System.nanoTime
      end
    else
      def time_in_nanoseconds
        t = Time.now
        t.to_i * 10**9 + t.nsec
      end
    end
  end
end
