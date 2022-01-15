require "minitest/autorun"

require "/../src/chronos"

class ChronosTest < Minitest::Test
  def test_initializes_chronos
    scheduler = Chronos.new

    assert_equal 0, scheduler.tasks.size
    assert_equal Time::Location.local, scheduler.location
  end

  def test_adds_one_time_task_with_at
    test_val = 0
    scheduler = Chronos.new

    scheduler.at(3.milliseconds.from_now) do
      test_val = 5
    end

    task = scheduler.tasks.first
    assert_equal Chronos::OneTimeTask, task.class
    scheduler.run

    sleep 2.milliseconds
    assert_equal 0, test_val

    sleep 4.milliseconds
    assert_equal 5, test_val

    assert_equal 0, scheduler.tasks.size
  end

  def test_adds_one_time_task_with_in
    test_val = 0
    scheduler = Chronos.new

    scheduler.in(3.milliseconds) do
      test_val = 5
    end

    task = scheduler.tasks.first
    assert_equal Chronos::OneTimeTask, task.class
    scheduler.run

    sleep 2.milliseconds
    assert_equal 0, test_val

    sleep 4.milliseconds
    assert_equal 5, test_val
  end

  def test_adds_multiple_tasks_out_of_order
    test_val = 0
    scheduler = Chronos.new
    scheduler.run

    scheduler.in(6.milliseconds) do
      test_val = 10
    end

    scheduler.in(2.milliseconds) do
      test_val = 5
    end

    assert_equal 0, test_val

    sleep 4.milliseconds
    assert_equal 5, test_val

    sleep 4.milliseconds
    assert_equal 10, test_val
  end

  def test_executes_multiple_tasks_at_same_time
    test_val = 0
    scheduler = Chronos.new

    execute_time = 3.milliseconds.from_now

    scheduler.at(execute_time) { test_val += 5 }

    scheduler.at(execute_time) { test_val += 5 }

    scheduler.run

    sleep 5.milliseconds
    assert_equal 10, test_val
  end

  def test_executes_periodic_task_periodically
    test_val = 0
    scheduler = Chronos.new
    scheduler.run

    period = 10.milliseconds

    scheduler.every(period) do
      test_val += 5
    end

    assert_equal 0, test_val
    sleep 15.milliseconds
    assert_equal 5, test_val
    sleep 10.milliseconds
    assert_equal 10, test_val
  end

  def test_executes_periodic_task_with_start
    test_val = 0
    scheduler = Chronos.new
    scheduler.run

    period = 20.milliseconds
    start_time = 10.milliseconds.from_now

    scheduler.every(period, start_time) do
      test_val += 5
    end

    assert_equal 0, test_val
    sleep 15.milliseconds
    assert_equal 5, test_val
    sleep 10.milliseconds
    assert_equal 5, test_val
    sleep 10.milliseconds
    assert_equal 10, test_val
  end

  def test_adds_recurring_task
    test_val = 0
    scheduler = Chronos.new
    scheduler.run

    now = Time.local

    scheduler.every(:minute, {second: now.second + 1}) do
      test_val = 5
    end

    assert_equal 0, test_val
    sleep 1.seconds
    assert_equal 5, test_val
  end

  def test_outputs_error
    error_file = "errors.txt"

    scheduler = Chronos.new
    scheduler.stderr = File.new(error_file, "w")

    scheduler.in(2.milliseconds) do
      raise RuntimeError.new("Random error")
    end

    scheduler.run
    sleep 4.milliseconds

    log = File.read(error_file)
    assert_equal 1, log.lines.size
    assert log.includes?("RuntimeError - Random error")

    File.delete(error_file) if File.exists?(error_file)
  end

  def test_handles_error_block
    log_file = "log.txt"
    scheduler = Chronos.new

    scheduler.on_error do |ex|
      File.write(log_file, ex.message, mode: "w")
    end

    scheduler.in(2.milliseconds) do
      raise RuntimeError.new("Random error")
    end

    scheduler.run
    sleep 4.milliseconds

    log = File.read(log_file)
    assert_equal 1, log.lines.size
    assert log.includes?("Random error")

    File.delete(log_file) if File.exists?(log_file)
  end
end
