require "./task"

class Chronos
  class PeriodicTask < Task
    @period : Time::Span
    @next_run : Time

    def initialize(@period : Time::Span, first_run = nil, &@block)
      if @period < Time::Span::ZERO
        raise "Invalid period"
      end

      @next_run = first_run || Time.local + @period
      @id = "Periodic#{next_id}"
    end

    def next_run : Time
      @next_run
    end

    def run
      @next_run += @period
      super
    end
  end
end
