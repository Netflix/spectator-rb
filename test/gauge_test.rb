require 'test_helper'
require 'spectator/measure'

class GaugeTest < Minitest::Test
  def setup
    id = Spectator::MeterId.new('gauge')
    @gauge = Spectator::Gauge.new(id)
  end

  def test_increment
    assert @gauge.get.nan?
    @gauge.set(42.0)
    assert_equal(42.0, @gauge.get)
    @gauge.set(43.0)
    assert_equal(43.0, @gauge.get)
  end

  def test_measure
    @gauge.set(1000.0)
    ms = @gauge.measure
    assert_equal(1, ms.size)

    base = Spectator::MeterId.new('gauge')
    gauge = Spectator::Measure.new(base.with_stat('gauge'), 1000.0)

    expected = [gauge]
    assert_equal(expected, ms)

    ms = @gauge.measure
    assert_equal(1, ms.size)
    assert(ms[0].value.nan?)
  end
end
