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
    scheduler.run

    scheduler.at(3.milliseconds.from_now) do
      test_val = 5
    end

    task = scheduler.tasks.first
    assert_equal Chronos::OneTimeTask, task.class

    sleep 2.milliseconds
    assert_equal 0, test_val

    sleep 4.milliseconds
    assert_equal 5, test_val

    assert_equal 0, scheduler.tasks.size
  end

  def test_raises_error_on_adding_invalid_task
    scheduler = Chronos.new

    error = assert_raises do
      task = scheduler.at(-20.milliseconds.from_now) { puts "Hello, world!" }
    end

    assert_equal "Invalid date", error.message
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
    test_val = [] of String
    scheduler = Chronos.new
    scheduler.run
    start = Time.monotonic

    scheduler.in(40.milliseconds) do
      test_val << "#{(Time.monotonic - start).milliseconds // 10}"
    end

    scheduler.in(20.milliseconds) do
      test_val << "#{(Time.monotonic - start).milliseconds // 10}"
    end

    assert_equal [] of String, test_val
    sleep 50.milliseconds
    assert_equal ["2", "4"], test_val
  end

  def test_executes_multiple_tasks_at_same_time
    test_val = 0
    scheduler = Chronos.new

    execute_time = 4.milliseconds.from_now

    scheduler.at(execute_time) { test_val += 5 }

    scheduler.at(execute_time) { test_val += 5 }

    scheduler.run

    sleep 7.milliseconds
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

  def test_executes_recurring_task
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

  def test_executes_periodic_and_one_time_tasks
    test_val = [] of String
    scheduler = Chronos.new
    scheduler.run
    start = Time.monotonic

    scheduler.every(40.milliseconds) do
      test_val << "Periodic #{(Time.monotonic - start).milliseconds // 10}"
    end

    scheduler.in(60.milliseconds) do
      test_val << "One Time #{(Time.monotonic - start).milliseconds // 10}"
    end

    sleep 90.milliseconds
    assert_equal ["Periodic 4", "One Time 6", "Periodic 8"] of String, test_val
  end

  def test_deletes_task_with_id
    scheduler = Chronos.new

    task = scheduler.at(20.milliseconds.from_now) { puts "Hello, world!" }

    assert_equal 1, scheduler.tasks.size

    scheduler.delete_at(task.id)
    assert_equal 0, scheduler.tasks.size
  end

  def test_deletes_task_while_running
    test_val = false
    scheduler = Chronos.new
    scheduler.run

    scheduler.at(20.milliseconds.from_now) { test_val = true }
    scheduler.at(40.milliseconds.from_now) { test_val = true }

    assert_equal 2, scheduler.tasks.size

    task = scheduler.tasks.first
    scheduler.delete_at(task.id)
    assert_equal 1, scheduler.tasks.size

    sleep 30.milliseconds
    refute test_val
  end

  def test_raises_error_on_deleting_invalid_task
    scheduler = Chronos.new

    error = assert_raises do
      scheduler.delete_at("gibberish")
    end
    assert_equal IndexError, error.class

    scheduler.run

    error = assert_raises do
      scheduler.delete_at("gibberish")
    end
    assert_equal IndexError, error.class
  end

  def test_logs_error
    scheduler = Chronos.new

    scheduler.in(2.milliseconds) do
      raise RuntimeError.new("Random error")
    end

    assert_output(stdout: /\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}.*Error RuntimeError - Random error/) do
      scheduler.run
      sleep 4.milliseconds
    end
  end

  def test_uses_custom_log
    scheduler = Chronos.new

    error_file = "errors.txt"
    log = scheduler.log
    log.backend = Log::IOBackend.new(File.new(error_file, "w"))
    scheduler.log = log

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
end
