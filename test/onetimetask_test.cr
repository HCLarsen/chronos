require "minitest/autorun"

require "/../src/chronos/onetimetask"

class OneTimeTaskTest < Minitest::Test
  def test_initalizes_task
    @test_val = 0
    run_time = Time.local + 20.minutes
    task = Chronos::OneTimeTask.new(run_time) do
      @test_val = 5
    end

    assert_equal run_time, task.next_run

    task.run
    assert_equal 5, @test_val
  end

  def test_creates_unique_id
    run_time = Time.local + 20.minutes
    task1 = Chronos::OneTimeTask.new(run_time) { puts "Hello" }
    task2 = Chronos::OneTimeTask.new(run_time) { puts "Hello" }

    refute_equal task1.id, task2.id
  end

  def test_raises_for_past_date
    run_time = Time.local - 1.minutes

    error = assert_raises do
      task = Chronos::OneTimeTask.new(run_time) do
        puts "Hello world"
      end
    end

    assert_equal "Invalid date", error.message
  end
end
