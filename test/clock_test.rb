# frozen_string_literal: true

require 'test_helper'

class ClockTest < Minitest::Test
  def test_system_nano_works
    sc = Spectator::SystemClock.new
    start = sc.monotonic_time
    sleep(0.00001)
    elapsed = sc.monotonic_time - start
    refute_equal 0, elapsed
  end

  def test_system_wall_works
    sc = Spectator::SystemClock.new
    start = sc.wall_time
    sleep 1 / 1000.0
    elapsed = sc.wall_time - start
    assert elapsed >= 0.0009
  end
end
