require "minitest/autorun"

require "/../src/chronos/periodictask"

class PeriodicTaskTest < Minitest::Test
  def test_initalizes_task
    test_val = 0
    period = 100.milliseconds
    run_time = Time.local + period

    task = Chronos::PeriodicTask.new(period) do
      test_val = 5
    end

    assert_equal run_time.to_unix_ms, task.next_run.to_unix_ms

    sleep period

    task.run
    assert_equal (run_time + period).to_unix_ms, task.next_run.to_unix_ms
    assert_equal 5, test_val
  end

  def test_creates_unique_id
    period = 100.milliseconds
    task1 = Chronos::PeriodicTask.new(period) { puts "Hello" }
    task2 = Chronos::PeriodicTask.new(period) { puts "Hello" }

    refute_equal task1.id, task2.id
  end

  def test_initalizes_task_with_first_time
    test_val = 0
    period = 20.minutes
    start_time = Time.local + 10.minutes
    run_time = Time.local + period

    task = Chronos::PeriodicTask.new(period, start_time) do
      test_val = 5
    end

    assert_equal start_time.to_unix_ms, task.next_run.to_unix_ms

    task.run
    assert_equal 5, test_val
    assert_equal (start_time + period).to_unix_ms, task.next_run.to_unix_ms
  end

  def test_raises_for_negative_span
    period = -20.minutes

    error = assert_raises do
      task = Chronos::PeriodicTask.new(period) do
        puts "Hello world"
      end
    end

    assert_equal "Invalid period", error.message
  end
end
