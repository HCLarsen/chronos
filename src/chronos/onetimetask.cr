require "./task"

class Chronos
  class OneTimeTask < Task
    @run_time : Time

    def initialize(@run_time : Time, &@block)
      if @run_time < Time.local
        raise "Invalid date"
      end

      @id = "Onetime#{next_id}"
    end

    def next_run : Time
      @run_time
    end
  end
end
