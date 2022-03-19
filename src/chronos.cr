require "log"

require "./chronos/*"

# TODO: Write documentation for `Chronos`
class Chronos
  VERSION = "0.1.0"

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

  def initialize(@location = Time::Location.local)
  end

  def tasks : Array(Task)
    @task_mutex.synchronize do
      return @tasks
    end
  end

  def log : Log
    @log_mutex.synchronize do
      return @log
    end
  end

  def log=(log : Log)
    @log_mutex.synchronize do
      @log = log
    end
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
    @task_mutex.synchronize do
      if task = @tasks.find { |e| e.id == id  }
        @tasks.delete(task)

        reset_loop

        return true
      else
        raise IndexError.new
      end
    end
  end

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
