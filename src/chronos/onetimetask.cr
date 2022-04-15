require "./task"

class Chronos
  # `OneTimeTask` represents a task that is run only once, based on a
  # specified time.
  class OneTimeTask < Task
    @run_time : Time

    # Creates a `OneTimeTask` that will execute at *run_time*.
    #
    # ```
    # run_time = Time.local(2022, 1, 1, 0, 0, 0)
    # task = Chronos::OneTimeTask.new(run_time) do
    #   puts "Happy new year!"
    # end
    # ```
    def initialize(@run_time : Time, &@block)
      if @run_time < Time.local
        raise "Invalid date"
      end

      @id = "Onetime#{next_id}"
    end

    # Returns the scheduled `Time` for this task to execute its block.
    def next_run : Time
      @run_time
    end
  end
end
