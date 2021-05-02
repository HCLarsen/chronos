class Chronos
  abstract class Task
    @block : (->)

    def initialize(@block)
    end

    abstract def next_run : Time

    def run
      @block.call
    end
  end
end
