module Spectator
  # Thread safe number operations
  class AtomicNumber
    def initialize(init)
      @value = init
      @lock = Mutex.new
    end

    def set(value)
      @lock.synchronize { @value = value }
    end

    def get
      @lock.synchronize { @value }
    end

    def get_and_set(value)
      @lock.synchronize do
        tmp = @value
        @value = value
        tmp
      end
    end

    def get_and_add(amount)
      @lock.synchronize do
        tmp = @value
        @value += amount
        tmp
      end
    end

    def add_and_get(amount)
      @lock.synchronize { @value += amount }
    end

    def max(value)
      @lock.synchronize do
        @value = value if value > @value || @value.nan?
      end
    end

    def to_s
      "AtomicNumber{#{@value}}"
    end
  end
end
