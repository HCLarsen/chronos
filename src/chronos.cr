# TODO: Write documentation for `Chronos`
class Chronos
  VERSION = "0.1.0"

  property location : Time::Location
  getter tasks = [] of Task

  def initialize(@location = Time::Location.local)
  end

  def at(run_time : Time, &block)
    add_task OneTimeTask.new(run_time, &block)
  end

  def in(span : Time::Span, &block)
    at(span.from_now, &block)
  end

  def run
    spawn do
      loop do
        if first_task = @tasks.shift?
          wait = first_task.next_run - Time.local
          sleep wait
          first_task.run
        else
          sleep
        end
      end
    end
  end

  private def add_task(new_task : Task)
    @tasks << new_task
    @tasks.sort_by! { |task| task.next_run }
  end
end
