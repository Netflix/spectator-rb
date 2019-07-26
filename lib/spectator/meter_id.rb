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
     
    # Create a new MeterId adding the given tags
    def with_tags(additional_tags)
      new_tags = @tags.dup
      additional_tags.each do |k, v|
        new_tags[k] = v
      end
      MeterId.new(@name, new_tags)
    end

    # Create a new MeterId with key=statistic and the given value
    def with_stat(stat_value)
      with_tag(:statistic, stat_value)
    end
     
    # Get a MeterId with a statistic tag. If the current MeterId
    # already includes statistic then just return it, otherwise create
    # a new one
    def with_default_stat(stat_value)
      if tags.key?(:statistic)
        self
      else 
        with_tag(:statistic, stat_value)
      end
    end

    # lazyily compute a key to be used in hashes for efficiency
    def key
      @key ||= begin
        "#{name}|" << @tags.keys.sort.map do |k|
          [k, @tags[k]]
        end.flatten.join('|')
      end
    end

    # A string representation for debugging purposes
    def to_s
      "MeterId{name=#{@name}, tags=#{@tags}}".freeze
    end

    # Compare our id and tags against another MeterId
    def ==(other)
      other.name == @name && other.tags == @tags
    end
  end
end
