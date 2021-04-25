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
end
