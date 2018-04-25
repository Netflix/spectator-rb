module Spectator
  # This immutable class represents a measurement sampled from a meter
  class Measure
    attr_reader :id, :value

    # A meter id and a value
    def initialize(id, value)
      @id = id
      @value = value.to_f
    end

    # A string representation of this measurement, for debugging purposes
    def to_s
      "Measure{id=#{@id}, value=#{@value}}"
    end

    # Compare this measurement against another one,
    # taking into account nan values
    def ==(other)
      @id == other.id && (@value == other.value ||
          @value.nan? && other.value.nan?)
    end
  end
end
