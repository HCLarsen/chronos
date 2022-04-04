require "./task"

class Chronos
  class RecurringTask < Task
    # :nodoc:
    FREQUENCIES = [:year, :month, :day, :hour, :minute, :second, :week]

    @frequency : Symbol
    @times : Array(Hash(Symbol, Int32))

    def initialize(@frequency : Symbol, time : NamedTuple, &@block)
      if !FREQUENCIES.includes? @frequency
        raise "Invalid frequency"
      end

      @times = [time.to_h]
      @id = "Recurring#{next_id}"
    end

    def initialize(@frequency : Symbol, times : Array(NamedTuple), &@block)
      if !FREQUENCIES.includes? @frequency
        raise "Invalid frequency"
      end

      @times = times.map { |e| e.to_h }
      @id = "Recurring#{next_id}"
    end

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

    def beginning_time_components(time : Time) : Hash(Symbol, Int32)
      if @frequency == :week
        FREQUENCIES.index(:day)
      else
        index = FREQUENCIES.index(@frequency)
      end

      time_components(time).select(FREQUENCIES[0..index])
    end

    def time_components(time : Time) : Hash(Symbol, Int32)
      components = {} of Symbol => Int32

      components[:year] = time.year
      components[:month] = time.month
      components[:day] = time.day
      components[:hour] = time.hour
      components[:minute] = time.minute
      components[:second] = time.second

      components
    end

    def shift_time_by_frequency(time : Time) : Time
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
