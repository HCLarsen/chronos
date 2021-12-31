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

    sleep 4.milliseconds
    sleep 1.milliseconds
    assert_equal 10, test_val
  end
end
