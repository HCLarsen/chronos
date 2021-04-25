require "./task"

class Chronos
  class PeriodicTask < Task
    @period : Time::Span
    @last_run : Time

    def initialize(@period : Time::Span, &@block)
      @last_run = Time.local
    end

    def next_run : Time
      @last_run + @period
    end
  end
end
