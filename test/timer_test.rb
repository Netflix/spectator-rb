require 'test_helper'
require 'spectator/clock'
require 'spectator/measure'

class TimerTest < Minitest::Test
  def setup
    @clock = Spectator::ManualClock.new
    id = Spectator::MeterId.new('timer')
    @timer = Spectator::Timer.new(id, @clock)
  end

  def test_record
    assert_equal(0, @timer.count)
    assert_equal(0, @timer.total_time)
    @timer.record(1000)
    assert_equal(1, @timer.count)
    assert_equal(1000, @timer.total_time)
    @timer.record(2000)
    assert_equal(2, @timer.count)
    assert_equal(3000, @timer.total_time)
    @timer.record(-1)
    assert_equal(2, @timer.count)
    assert_equal(3000, @timer.total_time)
  end

  def test_time
    @clock.monotonic_time = 1
    @timer.time { @clock.monotonic_time = 5001 }
    assert_equal(1, @timer.count)
    assert_equal(5000, @timer.total_time)
  end

  def test_system_clock_time
    timer = Spectator::Timer.new(Spectator::MeterId.new('foo'))
    timer.time { sleep 0.001 }
    assert_equal(1, timer.count)
    assert_operator(timer.total_time, '>=', 1e6)
  end

  def test_measure
    @timer.record(1e6)
    ms = @timer.measure
    assert_equal(4, ms.size)

    base = Spectator::MeterId.new('timer')
    count = Spectator::Measure.new(base.with_stat('count'), 1)
    total = Spectator::Measure.new(base.with_stat('totalTime'), 0.001)
    total_sq = Spectator::Measure.new(base.with_stat('totalOfSquares'), 1e-6)
    max = Spectator::Measure.new(base.with_stat('max'), 0.001)

    expected = [count, total, total_sq, max]
    assert_equal(expected, ms)
  end
end
