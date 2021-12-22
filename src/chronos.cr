# TODO: Write documentation for `Chronos`
class Chronos
  VERSION = "0.1.0"

  property location : Time::Location
  getter tasks = [] of Task

  def initialize(@location = Time::Location.local)
  end

  def at(run_time : Time, &block)
    @tasks << OneTimeTask.new(run_time, &block)
  end

  def in(span : Time::Span, &block)
    at(span.from_now, &block)
  end

  def run
    spawn do
      first_task = @tasks.shift
      wait = first_task.next_run - Time.local
      sleep wait
      first_task.run
    end
  end
end
