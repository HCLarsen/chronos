require "./task"

class Chronos
  class OneTimeTask < Task
    @run_time : Time

    def initialize(@run_time : Time, &@block)
    end

    def next_run : Time
      @run_time
    end
  end
end
