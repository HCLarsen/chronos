require "./task"

class Chronos
  # `PeriodicTask` represents a task that runs at a specified period, with
  # an optional first run time.
  #
  # ### Difference from `RecurringTask`
  #
  # The significant difference between a `PeriodicTask` and a `RecurringTask`
  # is that a *period* is based on the amount of time passing, and a
  # `RecurringTask` executes based on the time components.
  #
  # For example, a `PeriodicTask` with a period of 1 day, with a *first_run*
  # at 9:00PM, will execute at 9:00PM until Daylight Saving Time takes effect,
  # and then it will execute at 10:00PM every day until Daylight Saving Time
  # ends.
  #
  # On the other hand, a `RecurringTask` with a frequency of days, and a time
  # component specifying 9:00PM, will always execute at the same time every
  # day, regardless of Daylight Saving Time, or any other potential change
  # in the time zone offset.
  class PeriodicTask < Task
    @period : Time::Span
    @next_run : Time

    # Creates a `PeriodicTask` with the specified *period*, and an optional
    # *first_run* time.
    def initialize(@period : Time::Span, first_run = nil, &@block)
      if @period < Time::Span::ZERO
        raise "Invalid period"
      end

      @next_run = first_run || Time.local + @period
      @id = "Periodic#{next_id}"
    end

    # :inherit:
    def next_run : Time
      @next_run
    end

    # :inherit:
    def run
      @next_run += @period
      super
    end
  end
end
