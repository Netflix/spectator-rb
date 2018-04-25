require 'test_helper'

class MeasureTest < Minitest::Test
  def test_to_s
    id = Spectator::MeterId.new('name')
    m = Spectator::Measure.new(id, 42)

    assert_equal("Measure{id=#{id}, value=42.0}", m.to_s)
  end

  def test_equal
    id = Spectator::MeterId.new('name', test: 'val')
    m1 = Spectator::Measure.new(id, 42.0)

    id2 = Spectator::MeterId.new('name', 'test' => 'val')
    m2 = Spectator::Measure.new(id2, 42)

    assert_equal(m1, m2)
  end

  def test_equal_nan
    id = Spectator::MeterId.new('name', test: 'val')
    m1 = Spectator::Measure.new(id, Float::NAN)

    id2 = Spectator::MeterId.new('name', 'test' => 'val')
    m2 = Spectator::Measure.new(id2, Float::NAN)

    assert_equal(m1, m2)
  end
end
