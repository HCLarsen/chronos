# TODO: Write documentation for `Chronos`
class Chronos
  VERSION = "0.1.0"

  property location : Time::Location
  getter tasks = [] of Task

  def initialize(@location = Time::Location.local)
  end

  def in(span : Time::Span, &block)
    run_time = Time.local + span
    @tasks << OneTimeTask.new(run_time, &block)
  end

  def run
    spawn do
      first_task = @tasks.first
      wait = first_task.next_run - Time.local
      sleep wait
      @tasks.first.run
    end
  end
end
