class Chronos
  class InChannel(T) < Channel(T)
    @sender : Fiber?

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
      @sender = Fiber.current

      super(value)
      receiver.resume
    end

    def receive
      if sender = @sender
        sender.enqueue
      end
      
      super
    end

    # protected def receive_internal
    #   if (queue = @queue) && !queue.empty?
    #     puts "First"
    #     if sender_ptr = dequeue_sender
    #       puts sender_ptr.value.fiber
    #     end
    #
    #     deque_value = queue.shift
    #     if sender_ptr = dequeue_sender
    #       queue << sender_ptr.value.data
    #       sender_ptr.value.state = DeliveryState::Delivered
    #       sender_ptr.value.fiber.enqueue
    #     end
    #
    #     {DeliveryState::Delivered, deque_value}
    #   elsif sender_ptr = dequeue_sender
    #     puts "Second"
    #     value = sender_ptr.value.data
    #     sender_ptr.value.state = DeliveryState::Delivered
    #     sender_ptr.value.fiber.enqueue
    #
    #     {DeliveryState::Delivered, value}
    #   elsif @closed
    #     {DeliveryState::Closed, UseDefault.new}
    #   else
    #     {DeliveryState::None, UseDefault.new}
    #   end
    # end
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
