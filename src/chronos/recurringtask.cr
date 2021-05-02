require "./task"

class Chronos
  class RecurringTask < Task
    @time : NamedTuple(days: Int32, hours: Int32, minutes: Int32, seconds: Int32)

    def initialize(@frequency : Symbol, time : NamedTuple, &@block)
      @time = {days: 0, hours: 0, minutes: 0, seconds: 0}.merge(time)
    end

    def next_run : Time
      time = Time.local.time_of_day
      time_difference = Time::Span.new(**@time) - time
      beginning = Time.local.at_beginning_of_day
      if (time_difference < Time::Span::ZERO)
        beginning = beginning.shift(days: 1)
      end

      return beginning.shift(**@time)
    end
  end
end
