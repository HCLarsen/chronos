require "./task"

class Chronos
  # A `RecurringTask` is a `Task` that runs at a specified frequency, at
  # at specified times, set by a `NamedTuple` of time components.
  #
  # ### Difference from `PeriodicTask`
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
  #
  # ### Valid Settings
  #
  # There are seven valid frequencies:
  #
  # ```
  # :year, :month, :day, :hour, :minute, :second, :week
  # ```
  # There are five valid time components:
  #
  # ```
  # :month      # Month of the year, only valid for yearly events.
  # :day        # Day of month.
  # :dayOfWeek  # Specifies the day of the week as an integer.
  # :hour       # Hour of day, based on a 24 hour clock.
  # :minute     # Minute within the hour.
  # :second     # Second within the minute.
  # ```
  #
  # Times are always calculated based on `Time::Location.local`
  #
  # All time compoent values must be specified as `Int32`. At this time,
  # negative values, i.e., counting backwards from the end of the period,
  # are not accepted.
  #
  # NOTE: `:dayOfWeek` is incompatible with `:day`, and attempting to use both
  # will raise an error during initialization.
  class RecurringTask < Task
    # :nodoc:
    FREQUENCIES = [:year, :month, :day, :hour, :minute, :second, :week]

    @frequency : Symbol
    @times : Array(Hash(Symbol, Int32))

    # Creates a new `RecurringTask` with the given frequency and a single set
    # of time components.
    #
    # ```
    # task = Chronos::RecurringTask.new(:day, {hour: 8, minute: 30}) do
    #   puts "It's currently 8:30AM"
    # end
    # ```
    def initialize(@frequency : Symbol, time : NamedTuple, &@block)
      if !FREQUENCIES.includes? @frequency
        raise "Invalid frequency"
      end

      @times = [time.to_h]
      @id = "Recurring#{next_id}"
    end

    # Creates a new `RecurringTask` with the given frequency and multiple sets
    # of time components.
    #
    # ```
    # task = Chronos::RecurringTask.new(:month, times) do
    #   puts "Hello, world!"
    # end
    # ```
    def initialize(@frequency : Symbol, times : Array(NamedTuple), &@block)
      if !FREQUENCIES.includes? @frequency
        raise "Invalid frequency"
      end

      @times = times.map { |e| e.to_h }
      @id = "Recurring#{next_id}"
    end

    # :inherit:
    def next_run : Time
      now = Time.local
      blank_time_hash = {:year => 0, :month => 0, :day => 0, :hour => 0, :minute => 0, :second => 0}
      base_components = beginning_time_components(now)

      next_times = @times.map do |time|
        hash = blank_time_hash.merge(base_components).merge(time)

        if weekday = hash.delete(:dayOfWeek)
          days_away = weekday - now.day_of_week.value
          days_away += 7 if days_away < 0

          new_time = Time.local(**{year: Int32, month: Int32, day: Int32, hour: Int32, minute: Int32, second: Int32}.from(hash))

          new_time = new_time.shift(days: days_away)
        else
          new_time = Time.local(**{year: Int32, month: Int32, day: Int32, hour: Int32, minute: Int32, second: Int32}.from(hash))
        end

        if (new_time < now)
          shift_time_by_frequency(new_time)
        else
          new_time
        end
      end

      next_times.min
    end

    private def beginning_time_components(time : Time) : Hash(Symbol, Int32)
      if @frequency == :week
        FREQUENCIES.index(:day)
      else
        index = FREQUENCIES.index(@frequency)
      end

      time_components(time).select(FREQUENCIES[0..index])
    end

    private def time_components(time : Time) : Hash(Symbol, Int32)
      components = {} of Symbol => Int32

      components[:year] = time.year
      components[:month] = time.month
      components[:day] = time.day
      components[:hour] = time.hour
      components[:minute] = time.minute
      components[:second] = time.second

      components
    end

    private def shift_time_by_frequency(time : Time) : Time
      case @frequency
      when :year
        time.shift(years: 1)
      when :month
        time.shift(months: 1)
      when :week
        time.shift(days: 7)
      when :day
        time.shift(days: 1)
      when :hour
        time.shift(hours: 1)
      when :minute
        time.shift(minutes: 1)
      when :second
        time.shift(seconds: 1)
      else
        raise "Invalid frequency"
      end
    end
  end
end
