# frozen_string_literal: true

require 'test_helper'

class RegistryTest < Minitest::Test
  def setup
    @clock = Spectator::ManualClock.new
    @reg = Spectator::Registry.new({ common_tags: { 'nf.app': 'app' } },
                                   @clock)
  end

  def test_version
    refute_nil ::Spectator::VERSION
  end

  def test_new_id
    id = @reg.new_id('foo')
    assert_equal(Spectator::MeterId.new('foo'), id)
  end

  def test_counter
    c = @reg.counter('foo')
    assert_equal(0, c.count)
    c.increment
    assert_equal(1, c.count)

    c2 = @reg.counter('foo')
    assert_equal(1, c2.count)
  end

  def test_gauge
    g = @reg.gauge('gauge')
    assert(g.get.nan?)

    g.set(42)
    assert_equal(42, g.get)

    g2 = @reg.gauge('gauge')
    assert_equal(42, g2.get)
  end

  def test_dist_summary
    ds = @reg.distribution_summary('ds')
    assert_equal(0, ds.count)

    ds.record(42)
    assert_equal(1, ds.count)

    ds2 = @reg.distribution_summary('ds')
    assert_equal(42, ds2.total_amount)
  end

  def test_timer
    t = @reg.timer('latency')
    t2 = @reg.timer('latency')
    assert_same(t, t2)

    t.time { sleep(0.001) }
    ms = t.measure
    ms.each do |m|
      case m.id.tags[:statistic]
      when :count
        assert_equal(1, m.value)
      when :totalTime, :max
        assert(m.value >= 0.001 && m.value < 0.5)
      when :totalOfSquares
        assert(m.value >= 1e-6)
      else
        flunk "Unknown stat in #{m}"
      end
    end
  end

  # create a new Measure with the given name and stat
  def measure(name, stat, value)
    Spectator::Measure.new(@reg.new_id(name, statistic: stat), value)
  end

  def test_measurements
    @reg.counter('c').increment
    @reg.counter('d')
    @reg.gauge('f').set(10.0)
    @reg.gauge('g')

    ms = @reg.measurements
    sorted_ms = ms.sort_by { |m| m.id.name }
    expected = [
      measure('c', :count, 1),
      measure('d', :count, 0),
      measure('f', :gauge, 10.0),
      measure('g', :gauge, Float::NAN)
    ]
    assert_equal(expected, sorted_ms)
  end

  def test_publisher_ms
    @reg.counter('c').increment
    @reg.counter('d')
    @reg.gauge('f').set(10.0)
    @reg.gauge('g')

    ms = @reg.publisher.registry_measurements
    sorted_ms = ms.sort_by { |m| m.id.name }
    expected = [
      measure('c', 'count', 1),
      measure('f', 'gauge', 10.0)
    ]
    assert_equal(expected, sorted_ms)
  end

  def test_payload
    ms = [measure('c', 'count', 1), measure('f', 'gauge', 10.0)]
    payload = @reg.publisher.payload_for_measurements(ms)
    table = [8, :app, :c, :count, :f, :gauge, :name, :'nf.app', :statistic]
    c = [3, 6, 0, 7, 2, 5, 1, 0, 1]
    f = [3, 6, 0, 7, 4, 5, 3, 10, 10.0]
    table.concat(c).concat(f)
    assert_equal(table, payload)
  end

  def test_batch_size
    assert_equal(@reg.batch_size, Spectator::Registry::DEFAULT_BATCH_SIZE)
  end
end
