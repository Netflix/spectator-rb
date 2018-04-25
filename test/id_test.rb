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

  def test_key
    tags = { key: 'foo', key2: 'foo2' }
    id = Spectator::MeterId.new('test', tags)
    assert_equal('test|key|foo|key2|foo2', id.key)
    # second time should be cached
    assert_equal('test|key|foo|key2|foo2', id.key)
  end

  def test_string
    tags = { key: :foo, key2: :foo2 }
    id = Spectator::MeterId.new('test', tags)
    s = id.to_s
    assert_equal("MeterId{name=test, tags=#{tags}}", s)
  end
end
