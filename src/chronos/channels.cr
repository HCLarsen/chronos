class Chronos
  class InChannel(T) < Channel(T)
    def initialize
      super

      @queue = Deque(T).new
      @capacity = Int32::MAX
    end

    # Returns a boolean value indicating if there are any values in the channel
    def has_value : Bool
      if queue = @queue
        queue.size > 0
      else
        false
      end
    end

    def send(value : T, receiver : Fiber)
      super(value)
      receiver.resume
    end
  end

  class OutChannel(T) < Channel(T)
    def initialize
      super(1)
    end

    # Returns a boolean value indicating if there are any values in the channel
    def has_value : Bool
      if queue = @queue
        queue.size > 0
      else
        false
      end
    end

    def send(value : T)
      if queue = @queue
        queue.clear
      end

      super(value)
    end
  end
end
