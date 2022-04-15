class Chronos

  # Task is the base class for different types of tasks.
  #
  # Subclasses all contain a block of code to be run at the specified times,
  # but have different ways of scheduling the times to run.
  abstract class Task
    @@id_num : Int32 = 0

    # Returns the unique ID for this task.
    getter id : String

    @block : (->)

    # :nodoc:
    def initialize(@block)
      @id = ""
    end

    # Returns the next scheduled `Time` for this task to execute its block.
    abstract def next_run : Time

    # Executes the block of code specified at creation.
    def run
      @block.call
    end

    protected def next_id : Int32
      @@id_num += 1
    end
  end
end
