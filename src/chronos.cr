require "log"

require "./chronos/*"

# The Chronos class handles the execution and timing of a series of `Task`
# objects.
#
class Chronos
  VERSION = "0.1.1"

  LOG_FORMATTER = Log::Formatter.new do |entry, io|
    io << entry.timestamp.to_s("%Y/%m/%d %T %:z") << " [" << entry.source << "/" << Process.pid << "] "
    io << entry.severity << " " << entry.message
  end

  property location : Time::Location
  getter running = false

  @task_mutex = Mutex.new
  @log_mutex = Mutex.new
  @reset = false
  @tasks = [] of Task
  @main_fiber : Fiber?
  @log : Log = create_logger

  # Initializes a new `Chronos` instance, with the specified Location.
  def initialize(@location = Time::Location.local)
  end

  # Returns an array of all tasks currently scheduled by this isntance of
  # `Chronos`.
  def tasks : Array(Task)
    @task_mutex.synchronize do
      return @tasks
    end
  end

  # Returns the `Log` used by the `Chronos` instance
  def log : Log
    @log_mutex.synchronize do
      return @log
    end
  end

  # Assigns a `Log` object.
  def log=(log : Log)
    @log_mutex.synchronize do
      @log = log
    end
  end

  # Schedules a `OneTimeTask` that will run the code block at the specified
  # `Time`.
  def at(run_time : Time, &block) : Task
    add_task OneTimeTask.new(run_time, &block)
  end

  # Schedules a `OneTimeTask` that will run the code block at `Time::Span`
  # from the current time.
  def in(span : Time::Span, &block) : Task
    at(span.from_now, &block)
  end

  # Schedules a `PeriodicTask` that will run the code block repeatedly at the
  # specified interval.
  def every(period : Time::Span, &block) : Task
    add_task PeriodicTask.new(period, &block)
  end

  # Schedules a `PeriodicTask` that will run the code block repeatedly at the
  # specified interval, with the first execution to occur at *start_time*.
  def every(period : Time::Span, start_time : Time, &block) : Task
    add_task PeriodicTask.new(period, start_time, &block)
  end

  # Schedules a `RecurringTask` that will run the code block at recurring times
  # based on the frequency set by `period`, and occurring at times specified by
  # a `NamedTuple` of time components.
  #
  # See the `RecurringTask` documentation for a full listing of time components.
  def every(period : Symbol, time : NamedTuple, &block) : Task
    add_task RecurringTask.new(period, time, &block)
  end

  # Deleted the task specified by *id*.
  #
  # Returns an `IndexError` if *id* is not a valid task ID.
  #
  # NOTE: This will result in an error if *id* points to a `OneTimeTask` that
  # has already completed running.
  def delete_at(id : String) : Bool
    @task_mutex.synchronize do
      if task = @tasks.find { |e| e.id == id  }
        @tasks.delete(task)
      else
        raise IndexError.new
      end
    end

    reset_loop

    return true
  end

  # Runs the scheduler.
  def run : Nil
    @running = true

    main_fiber.enqueue

    Fiber.yield
  end

  private def main_fiber : Fiber
    if fiber = @main_fiber
      return fiber
    end

    @main_fiber = Fiber.new do
      loop do
        @reset = false
        wait : Time::Span? = nil

        @task_mutex.synchronize do
          if !@tasks.empty?
            wait = @tasks.first.next_run - Time.local
          end
        end

        if wait.nil?
          sleep
        elsif wait > 0.milliseconds
          sleep wait
        end

        @task_mutex.synchronize do
          if !@tasks.empty? && !@reset
            current_task = @tasks.first
            execute_task(current_task)

            if current_task.class == OneTimeTask
              @tasks.shift
            else
              sort_tasks
            end
          end
        end
      end
    end
  end

  private def execute_task(task : Task)
    spawn do
      begin
        task.run
      rescue ex
        @log_mutex.synchronize do
          @log.error { "#{ex.class} - #{ex.message}" }
        end
      end
    end

    sleep 1.milliseconds
  end

  private def add_task(new_task : Task) : Task
    @task_mutex.synchronize do
      @tasks << new_task
      sort_tasks
    end

    reset_loop

    new_task
  end

  private def reset_loop
    @reset = true
    if @running
      Fiber.current.enqueue
      main_fiber.resume
    end
  end

  private def sort_tasks
    @tasks.sort_by! { |task| task.next_run }
  end

  private def self.create_logger : Log
    log = Log.for(self)
    backend = Log::IOBackend.new(formatter: LOG_FORMATTER)
    log.backend = backend
    log
  end
end
