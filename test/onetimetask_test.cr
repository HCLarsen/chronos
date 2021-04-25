require "minitest/autorun"

require "/../src/chronos/onetimetask"

class OneTimeTaskTest < Minitest::Test
  def test_initalizes_task
    run_time = Time.local + 20.minutes
    task = Chronos::OneTimeTask.new(run_time)

    assert_equal run_time, task.next_run
  end
end
