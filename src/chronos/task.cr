class Chronos
  abstract class Task
    @@id_num : Int32 = 0
    getter id : String

    @block : (->)

    def initialize(@block)
      @id = ""
    end

    abstract def next_run : Time

    def run
      @block.call
    end

    protected def next_id : Int32
      @@id_num += 1
    end
  end
end
