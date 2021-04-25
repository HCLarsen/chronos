class Chronos
  class OneTimeTask
    @run_time : Time

    def initialize(@run_time : Time)
    end

    def next_run : Time
      @run_time
    end
  end
end
