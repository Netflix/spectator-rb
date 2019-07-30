# frozen_string_literal: true

require 'test_helper'

class NumberTest < Minitest::Test
  def test_getset
    n = Spectator::AtomicNumber.new(1)
    assert_equal(1, n.get)
    n.set(2)
    assert_equal(2, n.get)
  end

  def test_get_and_set
    n = Spectator::AtomicNumber.new(0)
    assert_equal(0, n.get)

    assert_equal(0, n.get_and_set(10))
    assert_equal(10, n.get_and_set(20))
    assert_equal(20, n.get)
  end

  def test_get_and_add
    n = Spectator::AtomicNumber.new(0)
    assert_equal(0, n.get)

    assert_equal(0, n.get_and_add(10))
    assert_equal(10, n.get_and_add(20))
    assert_equal(30, n.get)
  end

  def test_add_and_get
    n = Spectator::AtomicNumber.new(0)
    assert_equal(0, n.get)

    assert_equal(10, n.add_and_get(10))
    assert_equal(30, n.add_and_get(20))
    assert_equal(30, n.get)
  end

  def test_max
    n = Spectator::AtomicNumber.new(Float::NAN)
    assert(n.get.nan?)

    assert_equal(10, n.max(10))
    assert_equal(10, n.max(9))
    assert_equal(30, n.max(30))
    assert_equal(30, n.max(Float::NAN))
  end

  def test_to_s
    n = Spectator::AtomicNumber.new(42)
    assert_equal('AtomicNumber{42}', n.to_s)
  end
end
