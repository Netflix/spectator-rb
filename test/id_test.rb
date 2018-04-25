require 'test_helper'

class IdTest < Minitest::Test
  def test_tags_from_strings
    tags = { 'key' => 'val' }
    id = Spectator::MeterId.new('name', tags)
    expected = { key: :val }
    assert_equal(expected, id.tags)
  end

  def test_tags_from_symbols
    tags = { key: 'val' }
    id = Spectator::MeterId.new('name', tags)
    expected = { key: :val }
    assert_equal(expected, id.tags)

    tags = { key2: :val2 }
    id = Spectator::MeterId.new('name', tags)
    expected = { key2: :val2 }
    assert_equal(expected, id.tags)
  end

  def test_name_is_symbol
    id = Spectator::MeterId.new('name')
    assert_equal(:name, id.name)
  end
end
