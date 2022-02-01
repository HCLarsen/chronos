require "minitest/autorun"

require "/../src/chronos"
# require "/../src/chronos/onetimetask"

class InChannelTest < Minitest::Test
  def test_returns_has_value
    run_time = Time.local + 20.minutes
    task = Chronos::OneTimeTask.new(run_time) { puts "Testing" }

    add_channel = Chronos::InChannel(Chronos::Task).new

    refute add_channel.has_value
    add_channel.send(task)
    assert add_channel.has_value
  end

  def test_resumes_target_fibre
    test_array = [] of String
    main = Fiber.current

    add_channel = Chronos::InChannel(String).new

    fiber = spawn do
      sleep
      test_array << "Before Receive"
      test_array << add_channel.receive
      test_array << "After Receive"
      main.enqueue
    end

    assert test_array.empty?
    Fiber.yield

    test_array << "Before Send"
    add_channel.send("Sending", fiber)
    test_array << "After Send"

    assert_equal ["Before Send", "Before Receive", "Sending", "After Receive", "After Send"], test_array
  end
end

class OutChannelTest < Minitest::Test
  def test_returns_has_value
    out_channel = Chronos::OutChannel(String).new

    refute out_channel.has_value
    out_channel.send("Sending")
    assert out_channel.has_value
  end

  def test_sends_string_out_without_interruption
    test_array = [] of String
    out_channel = Chronos::OutChannel(String).new

    spawn do
      test_array << "Before Send"
      out_channel.send("Received")
      test_array << "After Send"
      sleep
    end

    assert test_array.empty?
    Fiber.yield

    test_array << "Before Receive"
    test_array << out_channel.receive
    test_array << "After Receive"

    assert_equal ["Before Send", "After Send", "Before Receive", "Received", "After Receive"], test_array
  end

  def test_replaces_queue_with_new_data
    test_array = [] of String
    out_channel = Chronos::OutChannel(String).new

    spawn do
      out_channel.send("First")
      out_channel.send("Second")
      sleep
    end

    assert test_array.empty?
    Fiber.yield

    test_array << out_channel.receive

    assert_equal ["Second"], test_array
    # Instead of adding new data to the queue, it should replace it with all the new data
  end
end
