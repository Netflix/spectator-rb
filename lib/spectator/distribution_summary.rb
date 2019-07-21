require 'spectator/atomic_number'

module Spectator
  # Track the sample distribution of events. An example would be the response
  # sizes for requests hitting an http server.
  #
  # The class will report measurements for the total amount, the count, max,
  # and the  total of the square of the amounts recorded
  # (useful for computing a standard deviation)
  class DistributionSummary
    # Initialize a new DistributionSummary instance with a given id
    def initialize(id)
      @id = id
      @count = AtomicNumber.new(0)
      @total_amount = AtomicNumber.new(0)
      @total_sq = AtomicNumber.new(0)
      @max = AtomicNumber.new(Float::NAN)
    end

    # Update the statistics kept by the summary with the specified amount.
    def record(amount)
      return if amount.negative?

      @count.add_and_get(1)
      @total_amount.add_and_get(amount)
      @total_sq.add_and_get(amount * amount)
      @max.max(amount)
    end

    # Get the current amount
    def count
      @count.get
    end

    # Return the total amount
    def total_amount
      @total_amount.get
    end

    # Get a list of measurements, and reset the stats
    # The stats returned are the current count, the total amount,
    # the sum of the square of the amounts recorded, and the max value
    def measure
      cnt = Measure.new(@id.with_stat('count'), @count.get_and_set(0))
      tot = Measure.new(@id.with_stat('totalAmount'),
                        @total_amount.get_and_set(0))
      tot_sq = Measure.new(@id.with_stat('totalOfSquares'),
                           @total_sq.get_and_set(0))
      mx = Measure.new(@id.with_stat('max'), @max.get_and_set(Float::NAN))

      [cnt, tot, tot_sq, mx]
    end
  end
end
