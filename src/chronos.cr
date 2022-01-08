require "./chronos/*"

# TODO: Write documentation for `Chronos`
class Chronos
  VERSION = "0.1.0"

  property location : Time::Location
  getter tasks = [] of Task
  @fiber : Fiber?
  @add_fiber : Fiber?

  def initialize(@location = Time::Location.local)
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
    spawn name: "Chronos-Main" do
      loop do
        size = @tasks.size
        if size > 0
          wait = @tasks.first.next_run - Time.local
          sleep wait if wait > 0.milliseconds

          if @tasks.size == size
            @tasks.first.run

            if @tasks.first.class == OneTimeTask
              @tasks.shift
            end
          end
        else
          sleep
        end

        if fiber = @add_fiber
          fiber.enqueue
          @add_fiber = nil
        end
      end
    end
  end

  private def add_task(new_task : Task)
    @tasks << new_task
    sort_tasks

    @add_fiber = Fiber.current

    if fiber = @fiber
      fiber.resume
    end
  end

  private def sort_tasks
    @tasks.sort_by! { |task| task.next_run }
  end
end
