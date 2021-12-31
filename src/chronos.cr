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

  def run
    spawn name: "Chronos-Main" do
      loop do
        size = @tasks.size
        if size > 0
          wait = @tasks.first.next_run - Time.local
          sleep [wait, 1.milliseconds].max

          if @tasks.size == size
            @tasks.shift.run
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
    @tasks.sort_by! { |task| task.next_run }

    @add_fiber = Fiber.current

    if fiber = @fiber
      fiber.resume
    end
  end
end
