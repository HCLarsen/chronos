require "./chronos/*"

# TODO: Write documentation for `Chronos`
class Chronos
  VERSION = "0.1.0"

  property location : Time::Location
  # getter tasks = [] of Task
  property stderr = STDERR
  getter running = false

  @tasks = [] of Task
  @main_fiber : Fiber?
  @add_fiber : Fiber?
  @on_error : (Exception ->)?
  @add_channel = Chronos::InChannel(Chronos::Task).new
  @out_channel = Chronos::OutChannel(Array(Chronos::Task)).new

  def initialize(@location = Time::Location.local)
    # @main_fiber = run
  end

  def on_error(&on_error : Exception ->)
    @on_error = on_error
  end

  def tasks
    if @out_channel.has_value
      @tasks = @out_channel.receive
    end

    @tasks
  end

  def at(run_time : Time, &block)
    add_task OneTimeTask.new(run_time, &block)
  end

  def in(span : Time::Span, &block)
    at(span.from_now, &block)
  end

  def every(period : Time::Span, &block)
    add_task PeriodicTask.new(period, &block)
  end

  def every(period : Time::Span, start_time : Time, &block)
    add_task PeriodicTask.new(period, start_time, &block)
  end

  def every(period : Symbol, time : NamedTuple, &block)
    add_task RecurringTask.new(period, time, &block)
  end

  def run
    tasks = Deque.new(@tasks)
    @running = true

    @main_fiber = spawn name: "Chronos-Main" do
      loop do
        size = tasks.size
        if size > 0
          wait = tasks.first.next_run - Time.local
          # puts "5. Sleeping #{wait.milliseconds}"
          sleep wait if wait > 0.milliseconds
        else
          # puts "2. Sleeping"
          sleep
        end

        if @add_channel.has_value
          tasks << @add_channel.receive
          tasks.sort_by! { |task| task.next_run }
        else
        # end
        #
        # if tasks.size == size && tasks.size > 0
          current_task = tasks.first
          execute_task(current_task)

          if current_task.class == OneTimeTask
            tasks.shift
          else
            # sort_tasks
            tasks.sort_by! { |task| task.next_run }
          end
        end

        if fiber = @add_fiber
          fiber.enqueue
          @add_fiber = nil
        end

        @out_channel.send(tasks.to_a)
      end
    end

    Fiber.yield
    # puts "1. Initialized"
  end

  private def main_fibre

  end

  private def execute_task(task : Task)
    begin
      task.run
    rescue ex
      if on_error = @on_error
        on_error.call(ex)
      else
        @stderr.puts "#{Time.local}: #{ex.class} - #{ex.message}"
        @stderr.flush
      end
    end
  end

  private def add_task(new_task : Task)
    # puts "3. Adding"

    if @running
      @add_fiber = Fiber.current
      fiber = @main_fiber.not_nil!
      @add_channel.send(new_task, fiber)
    else
      @tasks << new_task
      sort_tasks
    end

  end

  private def sort_tasks
    @tasks.sort_by! { |task| task.next_run }
  end
end
