require "minitest/autorun"
require "timecop"

require "/../src/chronos/recurringtask"

class RecurringTaskTest < Minitest::Test
  def test_initializes_task
    time_of_day = {hours: 8, minutes: 30}
    task = Chronos::RecurringTask.new(:day, time_of_day) do
      @test_val = 5
    end

    Timecop.travel(Time.local(2021, 5, 1, 7, 30, 0)) do
      assert_equal Time.local(2021, 5, 1, 8, 30, 0), task.next_run
    end

    Timecop.travel(Time.local(2021, 5, 1, 9, 30, 0)) do
      assert_equal Time.local(2021, 5, 2, 8, 30, 0), task.next_run
    end

    task.run
    assert_equal 5, @test_val
  end

  def test_calculates_next_across_timezone_change
    time_of_day = {hours: 8, minutes: 30}
    task = Chronos::RecurringTask.new(:day, time_of_day) do
      @test_val = 5
    end

    Timecop.travel(Time.local(2021, 11, 6, 9, 30, 0)) do
      assert_equal Time.local(2021, 11, 7, 8, 30, 0), task.next_run
    end
  end
end
