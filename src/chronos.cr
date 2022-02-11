require "./chronos/*"

# TODO: Write documentation for `Chronos`
class Chronos
  VERSION = "0.1.0"

  property location : Time::Location
  property stderr = STDERR
  getter running = false

  @tasks = [] of Task
  @main_fiber : Fiber?
  @on_error : (Exception ->)?
  @add_channel = Chronos::InChannel(Chronos::Task).new
  @delete_channel = Chronos::InChannel(String).new
  @out_channel = Chronos::OutChannel(Array(Chronos::Task)).new

  def initialize(@location = Time::Location.local)
  end

  def on_error(&on_error : Exception ->)
    @on_error = on_error
  end

  def tasks : Array(Task)
    update_tasks

    @tasks
  end

  def at(run_time : Time, &block) : Task
    add_task OneTimeTask.new(run_time, &block)
  end

  def in(span : Time::Span, &block) : Task
    at(span.from_now, &block)
  end

  def every(period : Time::Span, &block) : Task
    add_task PeriodicTask.new(period, &block)
  end

  def every(period : Time::Span, start_time : Time, &block) : Task
    add_task PeriodicTask.new(period, start_time, &block)
  end

  def every(period : Symbol, time : NamedTuple, &block) : Task
    add_task RecurringTask.new(period, time, &block)
  end

  def delete_at(id : String) : Bool
    if task = @tasks.find { |e| e.id == id  }
      if @running
        @delete_channel.send(id, main_fiber)
      else
        @tasks.delete(task)
      end

      return true
    else
      raise IndexError.new
    end
  end

  def run : Nil
    @running = true

    main_fiber

    Fiber.yield
    # puts "1. Initialized"
  end

  private def main_fiber : Fiber
    if fiber = @main_fiber
      return fiber
    end

    tasks = Deque.new(@tasks)

    @main_fiber = spawn do
      loop do
        if !tasks.empty?
          wait = tasks.first.next_run - Time.local
          # puts "5. Sleeping #{wait.milliseconds}"
          sleep wait if wait > 0.milliseconds
        else
          # puts "2. Sleeping"
          sleep
        end

        if @add_channel.has_value || @delete_channel.has_value
          if @add_channel.has_value
            tasks << @add_channel.receive
            tasks.sort_by! { |task| task.next_run }
          end
          if @delete_channel.has_value
            id = @delete_channel.receive
            task = tasks.find { |e| e.id == id  }
            tasks.delete(task)
          end
        elsif !tasks.empty?
          current_task = tasks.first
          execute_task(current_task)

          if current_task.class == OneTimeTask
            tasks.shift
          else
            tasks.sort_by! { |task| task.next_run }
          end
        end

        @out_channel.send(tasks.to_a)
      end
    end
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

  private def add_task(new_task : Task) : Task
    # puts "3. Adding"

    if @running
      @add_channel.send(new_task, main_fiber)
    else
      @tasks << new_task
      sort_tasks
    end

    new_task
  end

  private def update_tasks
    if @out_channel.has_value
      @tasks = @out_channel.receive
    end
  end

  private def sort_tasks
    @tasks.sort_by! { |task| task.next_run }
  end
end
