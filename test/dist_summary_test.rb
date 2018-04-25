require 'test_helper'
require 'spectator/measure'

class DistSummaryTest < Minitest::Test
  def setup
    id = Spectator::MeterId.new('ds')
    @dist_summary = Spectator::DistributionSummary.new(id)
  end

  def test_record
    assert_equal(0, @dist_summary.count)
    assert_equal(0, @dist_summary.total_amount)
    @dist_summary.record(1000)
    assert_equal(1, @dist_summary.count)
    assert_equal(1000, @dist_summary.total_amount)
    @dist_summary.record(2000)
    assert_equal(2, @dist_summary.count)
    assert_equal(3000, @dist_summary.total_amount)
    @dist_summary.record(-1)
    assert_equal(2, @dist_summary.count)
    assert_equal(3000, @dist_summary.total_amount)
  end

  def test_measure
    @dist_summary.record(1e6)
    ms = @dist_summary.measure
    assert_equal(4, ms.size)

    base = Spectator::MeterId.new('ds')
    count = Spectator::Measure.new(base.with_stat(:count), 1)
    total = Spectator::Measure.new(base.with_stat(:totalAmount), 1e6)
    total_sq = Spectator::Measure.new(base.with_stat(:totalOfSquares), 1e12)
    max = Spectator::Measure.new(base.with_stat(:max), 1e6)

    expected = [count, total, total_sq, max]
    assert_equal(expected, ms)
  end
end
