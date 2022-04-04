require "minitest/autorun"
require "timecop"

require "/../src/chronos/recurringtask"

class RecurringTaskTest < Minitest::Test
  def test_initializes_task
    time_of_day = {hour: 8, minute: 30}
    task = Chronos::RecurringTask.new(:day, time_of_day) do
      @test_val = 5
    end

    Timecop.travel(Time.local(2021, 5, 1, 7, 30, 5)) do
      assert_equal Time.local(2021, 5, 1, 8, 30, 0), task.next_run
    end

    Timecop.travel(Time.local(2021, 5, 1, 9, 30, 5)) do
      assert_equal Time.local(2021, 5, 2, 8, 30, 0), task.next_run
    end

    task.run
    assert_equal 5, @test_val
  end

  def test_creates_unique_id
    time_of_day = {hour: 8, minute: 30}
    task1 = Chronos::RecurringTask.new(:day, time_of_day) { puts "Hello" }
    task2 = Chronos::RecurringTask.new(:day, time_of_day) { puts "Hello" }

    refute_equal task1.id, task2.id
  end

  def test_initializes_other_frequencies
    task = Chronos::RecurringTask.new(:hour, {minute: 5}) do
      @test_val = 5
    end

    Timecop.travel(Time.local(2021, 5, 1, 7, 30, 5)) do
      assert_equal Time.local(2021, 5, 1, 8, 5, 0), task.next_run
    end
  end

  def test_initializes_weekly_task
    times = [{dayOfWeek: 1, hour: 12, minute: 15}]
    task = Chronos::RecurringTask.new(:week, times) do
      @test_val = 5
    end

    Timecop.travel(Time.local(2021, 11, 1, 9, 30, 0)) do
      assert_equal Time.local(2021, 11, 1, 12, 15, 0), task.next_run
    end

    Timecop.travel(Time.local(2021, 11, 1, 15, 30, 0)) do
      assert_equal Time.local(2021, 11, 8, 12, 15, 0), task.next_run
    end

    Timecop.travel(Time.local(2021, 11, 3, 9, 30, 0)) do
      assert_equal Time.local(2021, 11, 8, 12, 15, 0), task.next_run
    end
  end

  def test_initializes_with_multiple_times
    times = [{day: 1}, {day: 15}]
    task = Chronos::RecurringTask.new(:month, times) do
      @test_val = 5
    end

    Timecop.travel(Time.local(2021, 7, 2, 9, 30, 5)) do
      assert_equal Time.local(2021, 7, 15, 0, 0, 0), task.next_run
    end
  end

  def test_calculates_next_across_dst_change
    time_of_day = {hour: 8, minute: 30}
    task = Chronos::RecurringTask.new(:day, time_of_day) do
      @test_val = 5
    end

    Timecop.travel(Time.local(2021, 11, 6, 9, 30, 0)) do
      assert_equal Time.local(2021, 11, 7, 8, 30, 0), task.next_run
    end
  end

  def test_calculates_weekly_with_six_day_week
    local = Time::Location.local
    Time::Location.local = Time::Location.load("Pacific/Apia")

    times = [{dayOfWeek: 7, hour: 12, minute: 15}]
    task = Chronos::RecurringTask.new(:week, times) do
      @test_val = 5
    end

    Timecop.travel(Time.local(2011, 12, 26, 9, 30, 0)) do
      assert_equal Time.local(2012, 1, 1, 12, 15, 0), task.next_run
    end

    Time::Location.local = local
  end

  def test_raises_error_for_invalid_frequency
    error = assert_raises do
      task = Chronos::RecurringTask.new(:hours, {minute: 5}) do
        puts "Hello world"
      end
    end

    assert_equal "Invalid frequency", error.message
  end
end
