module Spectator
  # Identifier for a meter or Measure
  class MeterId
    attr_reader :name, :tags
    def initialize(name, maybe_tags = nil)
      tags = maybe_tags.nil? ? {} : maybe_tags
      @name = name.to_sym
      @tags = {}
      tags.each { |k, v| @tags[k.to_sym] = v.to_sym }
      @tags.freeze
      @key = nil
    end

    # Create a new MeterId with a given key and value
    def with_tag(key, value)
      new_tags = @tags.dup
      new_tags[key] = value
      MeterId.new(@name, new_tags)
    end

    # Create a new MeterId with key=statistic and the given value
    def with_stat(stat_value)
      with_tag(:statistic, stat_value)
    end

    # lazyily compute a key to be used in hashes for efficiency
    def key
      if @key.nil?
        hash_key = @name.to_s
        @key = hash_key
        keys = @tags.keys
        keys.sort
        keys.each do |k|
          v = tags[k]
          hash_key += "|#{k}|#{v}"
        end
        @key = hash_key
      end
      @key
    end

    # A string representation for debugging purposes
    def to_s
      "MeterId{name=#{@name}, tags=#{@tags}}"
    end

    # Compare our id and tags against another MeterId
    def ==(other)
      other.name == @name && other.tags == @tags
    end
  end
end
