require "minitest/autorun"

require "/../src/chronos/periodictask"

class PeriodicTaskTest < Minitest::Test
  def test_initalizes_task
    @test_val = 0
    period = 20.minutes
    run_time = Time.local + 20.minutes

    task = Chronos::PeriodicTask.new(period) do
      @test_val = 5
    end

    assert_equal Time.unix(seconds: run_time.to_unix), Time.unix(seconds: task.next_run.to_unix)

    task.run
    assert_equal 5, @test_val
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
