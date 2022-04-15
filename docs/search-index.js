crystal_doc_search_index_callback({"repository_name":"chronos","body":"# Chronos\n\nCrystal scheduling system.\n\n**WARNING** This shard has not been tested to be threadsafe.\n\n## Installation\n\n1. Add the dependency to your `shard.yml`:\n\n```yaml\ndependencies:\n  chronos:\n    github: HCLarsen/chronos\n```\n\n2. Run `shards install`\n\n## Usage\n\n```crystal\nrequire \"chronos\"\n\nscheduler = Chronos.new\n\nscheduler.in(5.minutes) do\n  # do something in 5 minutes\nend\n\nscheduler.at(Time.local(2022, 3, 12, 22, 0, 0, location: Time::Location.load(\"America/Toronto\"))) do\n  # do something at this specific point in time.\nend\n\nscheduler.every(1.hour) do\n  # do something every hour\nend\n\nscheduler.every(1.day, Time.local(2022, 3, 12, 22, 0, 0, location: Time::Location.load(\"America/Toronto\"))) do\n  # do something every hour starting at midnight on January 7th, 2022\nend\n\nscheduler.every(:day, {hour: 8, minute: 30}) do\n  # do something at 8:30AM every day\nend\n\nscheduler.run\n```\n\nTasks can be added to and deleted from the scheduler while running, without any interruption to execution.\n\n### Time Zones\n\nThe scheduler defaults to Time::Location.local for scheduling recurring events. This can be changed by setting the time zone in either the initializer, or after the fact.\n\n```crystal\nscheduler = Chronos.new(Time::Location.utc)\n\nscheduler.location = Time::Location.local\n```\n\n### Error Handling\n\nUnhandled exceptions raised when executing a task are logged to a [`Log`](https://crystal-lang.org/api/latest/Log.html) object.\n\n```\n2022-01-11 19:25:10 -05:00 [chronos/2452] Info: RuntimeError - Random error\n```\n\nA default log is created when a `Chronos` instance is initialized, but you can also set it to a custom logger.\n\n```crystal\nscheduler.log = Log.for(\"custom logger\")\n```\n\n## Development\n\nAll new features/modifications, must be properly tested using [Minitest.cr](https://github.com/ysbaddaden/minitest.cr). Any PRs without passing tests will not be merged.\n\nFeatures to be added:\n\n1. Add new `#every` for RecurringTask with multiple times.\n2. Add more error checking to RecurringTask for invalid time components and combinations.\n3. Time string parsing for Chronos methods.\n\n## Contributing\n\n1. Fork it (<https://github.com/HCLarsen/chronos/fork>)\n2. Create your feature branch (`git checkout -b my-new-feature`)\n3. Commit your changes (`git commit -am 'Add some feature'`)\n4. Push to the branch (`git push origin my-new-feature`)\n5. Create a new Pull Request\n\n## Contributors\n\n- [Chris Larsen](https://github.com/HCLarsen) - creator and maintainer\n","program":{"html_id":"chronos/toplevel","path":"toplevel.html","kind":"module","full_name":"Top Level Namespace","name":"Top Level Namespace","abstract":false,"locations":[],"repository_name":"chronos","program":true,"enum":false,"alias":false,"const":false,"types":[{"html_id":"chronos/Chronos","path":"Chronos.html","kind":"class","full_name":"Chronos","name":"Chronos","abstract":false,"superclass":{"html_id":"chronos/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"chronos/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"chronos/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/chronos.cr","line_number":8,"url":null},{"filename":"src/chronos/onetimetask.cr","line_number":3,"url":null},{"filename":"src/chronos/periodictask.cr","line_number":3,"url":null},{"filename":"src/chronos/recurringtask.cr","line_number":3,"url":null},{"filename":"src/chronos/task.cr","line_number":1,"url":null}],"repository_name":"chronos","program":false,"enum":false,"alias":false,"const":false,"constants":[{"id":"LOG_FORMATTER","name":"LOG_FORMATTER","value":"Log::Formatter.new do |entry, io|\n  (((((io << (entry.timestamp.to_s(\"%Y/%m/%d %T %:z\"))) << \" [\") << entry.source) << \"/\") << Process.pid) << \"] \"\n  ((io << entry.severity) << \" \") << entry.message\nend"},{"id":"VERSION","name":"VERSION","value":"\"0.1.1\""}],"doc":"The Chronos class handles the execution and timing of a series of `Task`\nobjects.\n","summary":"<p>The Chronos class handles the execution and timing of a series of <code><a href=\"Chronos/Task.html\">Task</a></code> objects.</p>","constructors":[{"html_id":"new(location=Time::Location.local)-class-method","name":"new","doc":"Initializes a new `Chronos` instance, with the specified Location.","summary":"<p>Initializes a new <code><a href=\"Chronos.html\">Chronos</a></code> instance, with the specified Location.</p>","abstract":false,"args":[{"name":"location","default_value":"Time::Location.local","external_name":"location","restriction":""}],"args_string":"(location = Time::Location.local)","args_html":"(location = <span class=\"t\">Time</span><span class=\"t\">::</span><span class=\"t\">Location</span>.local)","location":{"filename":"src/chronos.cr","line_number":27,"url":null},"def":{"name":"new","args":[{"name":"location","default_value":"Time::Location.local","external_name":"location","restriction":""}],"visibility":"Public","body":"_ = allocate\n_.initialize(location)\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"html_id":"at(run_time:Time,&block):Task-instance-method","name":"at","doc":"Schedules a `OneTimeTask` that will run the code block at the specified\n`Time`.","summary":"<p>Schedules a <code><a href=\"Chronos/OneTimeTask.html\">OneTimeTask</a></code> that will run the code block at the specified <code>Time</code>.</p>","abstract":false,"args":[{"name":"run_time","external_name":"run_time","restriction":"Time"}],"args_string":"(run_time : Time, &block) : Task","args_html":"(run_time : Time, &block) : <a href=\"Chronos/Task.html\">Task</a>","location":{"filename":"src/chronos.cr","line_number":54,"url":null},"def":{"name":"at","args":[{"name":"run_time","external_name":"run_time","restriction":"Time"}],"yields":0,"block_arg":{"name":"block","external_name":"block","restriction":""},"return_type":"Task","visibility":"Public","body":"add_task(OneTimeTask.new(run_time, &block))"}},{"html_id":"delete_at(id:String):Bool-instance-method","name":"delete_at","doc":"Deleted the task specified by *id*.\n\nReturns an `IndexError` if *id* is not a valid task ID.\n\nNOTE: This will result in an error if *id* points to a `OneTimeTask` that\nhas already completed running.","summary":"<p>Deleted the task specified by <em>id</em>.</p>","abstract":false,"args":[{"name":"id","external_name":"id","restriction":"String"}],"args_string":"(id : String) : Bool","args_html":"(id : String) : Bool","location":{"filename":"src/chronos.cr","line_number":91,"url":null},"def":{"name":"delete_at","args":[{"name":"id","external_name":"id","restriction":"String"}],"return_type":"Bool","visibility":"Public","body":"@task_mutex.synchronize do\n  if task = @tasks.find do |e|\n    e.id == id\n  end\n    @tasks.delete(task)\n  else\n    raise(IndexError.new)\n  end\nend\nreset_loop\nreturn true\n"}},{"html_id":"every(period:Time::Span,start_time:Time,&block):Task-instance-method","name":"every","doc":"Schedules a `PeriodicTask` that will run the code block repeatedly at the\nspecified interval, with the first execution to occur at *start_time*.","summary":"<p>Schedules a <code><a href=\"Chronos/PeriodicTask.html\">PeriodicTask</a></code> that will run the code block repeatedly at the specified interval, with the first execution to occur at <em>start_time</em>.</p>","abstract":false,"args":[{"name":"period","external_name":"period","restriction":"Time::Span"},{"name":"start_time","external_name":"start_time","restriction":"Time"}],"args_string":"(period : Time::Span, start_time : Time, &block) : Task","args_html":"(period : Time::Span, start_time : Time, &block) : <a href=\"Chronos/Task.html\">Task</a>","location":{"filename":"src/chronos.cr","line_number":72,"url":null},"def":{"name":"every","args":[{"name":"period","external_name":"period","restriction":"Time::Span"},{"name":"start_time","external_name":"start_time","restriction":"Time"}],"yields":0,"block_arg":{"name":"block","external_name":"block","restriction":""},"return_type":"Task","visibility":"Public","body":"add_task(PeriodicTask.new(period, start_time, &block))"}},{"html_id":"every(period:Symbol,time:NamedTuple,&block):Task-instance-method","name":"every","doc":"Schedules a `RecurringTask` that will run the code block at recurring times\nbased on the frequency set by `period`, and occurring at times specified by\na `NamedTuple` of time components.\n\nSee the `RecurringTask` documentation for a full listing of time components.","summary":"<p>Schedules a <code><a href=\"Chronos/RecurringTask.html\">RecurringTask</a></code> that will run the code block at recurring times based on the frequency set by <code>period</code>, and occurring at times specified by a <code>NamedTuple</code> of time components.</p>","abstract":false,"args":[{"name":"period","external_name":"period","restriction":"Symbol"},{"name":"time","external_name":"time","restriction":"NamedTuple"}],"args_string":"(period : Symbol, time : NamedTuple, &block) : Task","args_html":"(period : Symbol, time : NamedTuple, &block) : <a href=\"Chronos/Task.html\">Task</a>","location":{"filename":"src/chronos.cr","line_number":81,"url":null},"def":{"name":"every","args":[{"name":"period","external_name":"period","restriction":"Symbol"},{"name":"time","external_name":"time","restriction":"NamedTuple"}],"yields":0,"block_arg":{"name":"block","external_name":"block","restriction":""},"return_type":"Task","visibility":"Public","body":"add_task(RecurringTask.new(period, time, &block))"}},{"html_id":"every(period:Time::Span,&block):Task-instance-method","name":"every","doc":"Schedules a `PeriodicTask` that will run the code block repeatedly at the\nspecified interval.","summary":"<p>Schedules a <code><a href=\"Chronos/PeriodicTask.html\">PeriodicTask</a></code> that will run the code block repeatedly at the specified interval.</p>","abstract":false,"args":[{"name":"period","external_name":"period","restriction":"Time::Span"}],"args_string":"(period : Time::Span, &block) : Task","args_html":"(period : Time::Span, &block) : <a href=\"Chronos/Task.html\">Task</a>","location":{"filename":"src/chronos.cr","line_number":66,"url":null},"def":{"name":"every","args":[{"name":"period","external_name":"period","restriction":"Time::Span"}],"yields":0,"block_arg":{"name":"block","external_name":"block","restriction":""},"return_type":"Task","visibility":"Public","body":"add_task(PeriodicTask.new(period, &block))"}},{"html_id":"in(span:Time::Span,&block):Task-instance-method","name":"in","doc":"Schedules a `OneTimeTask` that will run the code block at `Time::Span`\nfrom the current time.","summary":"<p>Schedules a <code><a href=\"Chronos/OneTimeTask.html\">OneTimeTask</a></code> that will run the code block at <code>Time::Span</code> from the current time.</p>","abstract":false,"args":[{"name":"span","external_name":"span","restriction":"Time::Span"}],"args_string":"(span : Time::Span, &block) : Task","args_html":"(span : Time::Span, &block) : <a href=\"Chronos/Task.html\">Task</a>","location":{"filename":"src/chronos.cr","line_number":60,"url":null},"def":{"name":"in","args":[{"name":"span","external_name":"span","restriction":"Time::Span"}],"yields":0,"block_arg":{"name":"block","external_name":"block","restriction":""},"return_type":"Task","visibility":"Public","body":"at(span.from_now, &block)"}},{"html_id":"location:Time::Location-instance-method","name":"location","abstract":false,"location":{"filename":"src/chronos.cr","line_number":16,"url":null},"def":{"name":"location","return_type":"Time::Location","visibility":"Public","body":"@location"}},{"html_id":"location=(location:Time::Location)-instance-method","name":"location=","abstract":false,"args":[{"name":"location","external_name":"location","restriction":"Time::Location"}],"args_string":"(location : Time::Location)","args_html":"(location : Time::Location)","location":{"filename":"src/chronos.cr","line_number":16,"url":null},"def":{"name":"location=","args":[{"name":"location","external_name":"location","restriction":"Time::Location"}],"visibility":"Public","body":"@location = location"}},{"html_id":"log:Log-instance-method","name":"log","doc":"Returns the `Log` used by the `Chronos` instance","summary":"<p>Returns the <code>Log</code> used by the <code><a href=\"Chronos.html\">Chronos</a></code> instance</p>","abstract":false,"location":{"filename":"src/chronos.cr","line_number":39,"url":null},"def":{"name":"log","return_type":"Log","visibility":"Public","body":"@log_mutex.synchronize do\n  return @log\nend"}},{"html_id":"log=(log:Log)-instance-method","name":"log=","doc":"Assigns a `Log` object.","summary":"<p>Assigns a <code>Log</code> object.</p>","abstract":false,"args":[{"name":"log","external_name":"log","restriction":"Log"}],"args_string":"(log : Log)","args_html":"(log : Log)","location":{"filename":"src/chronos.cr","line_number":46,"url":null},"def":{"name":"log=","args":[{"name":"log","external_name":"log","restriction":"Log"}],"visibility":"Public","body":"@log_mutex.synchronize do\n  @log = log\nend"}},{"html_id":"run:Nil-instance-method","name":"run","doc":"Runs the scheduler.","summary":"<p>Runs the scheduler.</p>","abstract":false,"location":{"filename":"src/chronos.cr","line_number":106,"url":null},"def":{"name":"run","return_type":"Nil","visibility":"Public","body":"@running = true\nmain_fiber.enqueue\nFiber.yield\n"}},{"html_id":"running:Bool-instance-method","name":"running","abstract":false,"location":{"filename":"src/chronos.cr","line_number":17,"url":null},"def":{"name":"running","visibility":"Public","body":"@running"}},{"html_id":"tasks:Array(Task)-instance-method","name":"tasks","doc":"Returns an array of all tasks currently scheduled by this isntance of\n`Chronos`.","summary":"<p>Returns an array of all tasks currently scheduled by this isntance of <code><a href=\"Chronos.html\">Chronos</a></code>.</p>","abstract":false,"location":{"filename":"src/chronos.cr","line_number":32,"url":null},"def":{"name":"tasks","return_type":"Array(Task)","visibility":"Public","body":"@task_mutex.synchronize do\n  return @tasks\nend"}}],"types":[{"html_id":"chronos/Chronos/OneTimeTask","path":"Chronos/OneTimeTask.html","kind":"class","full_name":"Chronos::OneTimeTask","name":"OneTimeTask","abstract":false,"superclass":{"html_id":"chronos/Chronos/Task","kind":"class","full_name":"Chronos::Task","name":"Task"},"ancestors":[{"html_id":"chronos/Chronos/Task","kind":"class","full_name":"Chronos::Task","name":"Task"},{"html_id":"chronos/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"chronos/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/chronos/onetimetask.cr","line_number":6,"url":null}],"repository_name":"chronos","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"chronos/Chronos","kind":"class","full_name":"Chronos","name":"Chronos"},"doc":"`OneTimeTask` represents a task that is run only once, based on a\nspecified time.","summary":"<p><code><a href=\"../Chronos/OneTimeTask.html\">OneTimeTask</a></code> represents a task that is run only once, based on a specified time.</p>","constructors":[{"html_id":"new(run_time:Time,&block)-class-method","name":"new","doc":"Creates a `OneTimeTask` that will execute at *run_time*.\n\n```\nrun_time = Time.local(2022, 1, 1, 0, 0, 0)\ntask = Chronos::OneTimeTask.new(run_time) do\n  puts \"Happy new year!\"\nend\n```","summary":"<p>Creates a <code><a href=\"../Chronos/OneTimeTask.html\">OneTimeTask</a></code> that will execute at <em>run_time</em>.</p>","abstract":false,"args":[{"name":"run_time","external_name":"run_time","restriction":"Time"}],"args_string":"(run_time : Time, &block)","args_html":"(run_time : Time, &block)","location":{"filename":"src/chronos/onetimetask.cr","line_number":17,"url":null},"def":{"name":"new","args":[{"name":"run_time","external_name":"run_time","restriction":"Time"}],"yields":0,"block_arg":{"name":"block","external_name":"block","restriction":""},"visibility":"Public","body":"_ = allocate\n_.initialize(run_time, &block) do\n  yield\nend\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"html_id":"next_run:Time-instance-method","name":"next_run","doc":"Returns the scheduled `Time` for this task to execute its block.","summary":"<p>Returns the scheduled <code>Time</code> for this task to execute its block.</p>","abstract":false,"location":{"filename":"src/chronos/onetimetask.cr","line_number":26,"url":null},"def":{"name":"next_run","return_type":"Time","visibility":"Public","body":"@run_time"}}]},{"html_id":"chronos/Chronos/PeriodicTask","path":"Chronos/PeriodicTask.html","kind":"class","full_name":"Chronos::PeriodicTask","name":"PeriodicTask","abstract":false,"superclass":{"html_id":"chronos/Chronos/Task","kind":"class","full_name":"Chronos::Task","name":"Task"},"ancestors":[{"html_id":"chronos/Chronos/Task","kind":"class","full_name":"Chronos::Task","name":"Task"},{"html_id":"chronos/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"chronos/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/chronos/periodictask.cr","line_number":22,"url":null}],"repository_name":"chronos","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"chronos/Chronos","kind":"class","full_name":"Chronos","name":"Chronos"},"doc":"`PeriodicTask` represents a task that runs at a specified period, with\nan optional first run time.\n\n### Difference from `RecurringTask`\n\nThe significant difference between a `PeriodicTask` and a `RecurringTask`\nis that a *period* is based on the amount of time passing, and a\n`RecurringTask` executes based on the time components.\n\nFor example, a `PeriodicTask` with a period of 1 day, with a *first_run*\nat 9:00PM, will execute at 9:00PM until Daylight Saving Time takes effect,\nand then it will execute at 10:00PM every day until Daylight Saving Time\nends.\n\nOn the other hand, a `RecurringTask` with a frequency of days, and a time\ncomponent specifying 9:00PM, will always execute at the same time every\nday, regardless of Daylight Saving Time, or any other potential change\nin the time zone offset.","summary":"<p><code><a href=\"../Chronos/PeriodicTask.html\">PeriodicTask</a></code> represents a task that runs at a specified period, with an optional first run time.</p>","constructors":[{"html_id":"new(period:Time::Span,first_run=nil,&block)-class-method","name":"new","doc":"Creates a `PeriodicTask` with the specified *period*, and an optional\n*first_run* time.","summary":"<p>Creates a <code><a href=\"../Chronos/PeriodicTask.html\">PeriodicTask</a></code> with the specified <em>period</em>, and an optional <em>first_run</em> time.</p>","abstract":false,"args":[{"name":"period","external_name":"period","restriction":"Time::Span"},{"name":"first_run","default_value":"nil","external_name":"first_run","restriction":""}],"args_string":"(period : Time::Span, first_run = nil, &block)","args_html":"(period : Time::Span, first_run = <span class=\"n\">nil</span>, &block)","location":{"filename":"src/chronos/periodictask.cr","line_number":28,"url":null},"def":{"name":"new","args":[{"name":"period","external_name":"period","restriction":"Time::Span"},{"name":"first_run","default_value":"nil","external_name":"first_run","restriction":""}],"yields":0,"block_arg":{"name":"block","external_name":"block","restriction":""},"visibility":"Public","body":"_ = allocate\n_.initialize(period, first_run, &block) do\n  yield\nend\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"html_id":"next_run:Time-instance-method","name":"next_run","doc":"Returns the next scheduled `Time` for this task to execute its block.","summary":"<p>Returns the next scheduled <code>Time</code> for this task to execute its block.</p>","abstract":false,"location":{"filename":"src/chronos/periodictask.cr","line_number":38,"url":null},"def":{"name":"next_run","return_type":"Time","visibility":"Public","body":"@next_run"}},{"html_id":"run-instance-method","name":"run","doc":"Executes the block of code specified at creation.","summary":"<p>Executes the block of code specified at creation.</p>","abstract":false,"location":{"filename":"src/chronos/periodictask.cr","line_number":43,"url":null},"def":{"name":"run","visibility":"Public","body":"@next_run = @next_run + @period\nsuper()\n"}}]},{"html_id":"chronos/Chronos/RecurringTask","path":"Chronos/RecurringTask.html","kind":"class","full_name":"Chronos::RecurringTask","name":"RecurringTask","abstract":false,"superclass":{"html_id":"chronos/Chronos/Task","kind":"class","full_name":"Chronos::Task","name":"Task"},"ancestors":[{"html_id":"chronos/Chronos/Task","kind":"class","full_name":"Chronos::Task","name":"Task"},{"html_id":"chronos/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"chronos/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/chronos/recurringtask.cr","line_number":49,"url":null}],"repository_name":"chronos","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"chronos/Chronos","kind":"class","full_name":"Chronos","name":"Chronos"},"doc":"A `RecurringTask` is a `Task` that runs at a specified frequency, at\nat specified times, set by a `NamedTuple` of time components.\n\n### Difference from `PeriodicTask`\n\nThe significant difference between a `PeriodicTask` and a `RecurringTask`\nis that a *period* is based on the amount of time passing, and a\n`RecurringTask` executes based on the time components.\n\nFor example, a `PeriodicTask` with a period of 1 day, with a *first_run*\nat 9:00PM, will execute at 9:00PM until Daylight Saving Time takes effect,\nand then it will execute at 10:00PM every day until Daylight Saving Time\nends.\n\nOn the other hand, a `RecurringTask` with a frequency of days, and a time\ncomponent specifying 9:00PM, will always execute at the same time every\nday, regardless of Daylight Saving Time, or any other potential change\nin the time zone offset.\n\n### Valid Settings\n\nThere are seven valid frequencies:\n\n```\n:year, :month, :day, :hour, :minute, :second, :week\n```\nThere are five valid time components:\n\n```\n:month      # Month of the year, only valid for yearly events.\n:day        # Day of month.\n:dayOfWeek  # Specifies the day of the week as an integer.\n:hour       # Hour of day, based on a 24 hour clock.\n:minute     # Minute within the hour.\n:second     # Second within the minute.\n```\n\nTimes are always calculated based on `Time::Location.local`\n\nAll time compoent values must be specified as `Int32`. At this time,\nnegative values, i.e., counting backwards from the end of the period,\nare not accepted.\n\nNOTE: `:dayOfWeek` is incompatible with `:day`, and attempting to use both\nwill raise an error during initialization.","summary":"<p>A <code><a href=\"../Chronos/RecurringTask.html\">RecurringTask</a></code> is a <code><a href=\"../Chronos/Task.html\">Task</a></code> that runs at a specified frequency, at at specified times, set by a <code>NamedTuple</code> of time components.</p>","constructors":[{"html_id":"new(frequency:Symbol,time:NamedTuple,&block)-class-method","name":"new","doc":"Creates a new `RecurringTask` with the given frequency and a single set\nof time components.\n\n```\ntask = Chronos::RecurringTask.new(:day, {hour: 8, minute: 30}) do\n  puts \"It's currently 8:30AM\"\nend\n```","summary":"<p>Creates a new <code><a href=\"../Chronos/RecurringTask.html\">RecurringTask</a></code> with the given frequency and a single set of time components.</p>","abstract":false,"args":[{"name":"frequency","external_name":"frequency","restriction":"Symbol"},{"name":"time","external_name":"time","restriction":"NamedTuple"}],"args_string":"(frequency : Symbol, time : NamedTuple, &block)","args_html":"(frequency : Symbol, time : NamedTuple, &block)","location":{"filename":"src/chronos/recurringtask.cr","line_number":64,"url":null},"def":{"name":"new","args":[{"name":"frequency","external_name":"frequency","restriction":"Symbol"},{"name":"time","external_name":"time","restriction":"NamedTuple"}],"yields":0,"block_arg":{"name":"block","external_name":"block","restriction":""},"visibility":"Public","body":"_ = allocate\n_.initialize(frequency, time, &block) do\n  yield\nend\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}},{"html_id":"new(frequency:Symbol,times:Array(NamedTuple),&block)-class-method","name":"new","doc":"Creates a new `RecurringTask` with the given frequency and multiple sets\nof time components.\n\n```\ntask = Chronos::RecurringTask.new(:month, times) do\n  puts \"Hello, world!\"\nend\n```","summary":"<p>Creates a new <code><a href=\"../Chronos/RecurringTask.html\">RecurringTask</a></code> with the given frequency and multiple sets of time components.</p>","abstract":false,"args":[{"name":"frequency","external_name":"frequency","restriction":"Symbol"},{"name":"times","external_name":"times","restriction":"Array(NamedTuple)"}],"args_string":"(frequency : Symbol, times : Array(NamedTuple), &block)","args_html":"(frequency : Symbol, times : Array(NamedTuple), &block)","location":{"filename":"src/chronos/recurringtask.cr","line_number":81,"url":null},"def":{"name":"new","args":[{"name":"frequency","external_name":"frequency","restriction":"Symbol"},{"name":"times","external_name":"times","restriction":"Array(NamedTuple)"}],"yields":0,"block_arg":{"name":"block","external_name":"block","restriction":""},"visibility":"Public","body":"_ = allocate\n_.initialize(frequency, times, &block) do\n  yield\nend\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"html_id":"next_run:Time-instance-method","name":"next_run","doc":"Returns the next scheduled `Time` for this task to execute its block.","summary":"<p>Returns the next scheduled <code>Time</code> for this task to execute its block.</p>","abstract":false,"location":{"filename":"src/chronos/recurringtask.cr","line_number":91,"url":null},"def":{"name":"next_run","return_type":"Time","visibility":"Public","body":"now = Time.local\nblank_time_hash = {:year => 0, :month => 0, :day => 0, :hour => 0, :minute => 0, :second => 0}\nbase_components = beginning_time_components(now)\nnext_times = @times.map do |time|\n  hash = (blank_time_hash.merge(base_components)).merge(time)\n  if weekday = hash.delete(:dayOfWeek)\n    days_away = weekday - now.day_of_week.value\n    if days_away < 0\n      days_away = days_away + 7\n    end\n    new_time = Time.local(**{year: Int32, month: Int32, day: Int32, hour: Int32, minute: Int32, second: Int32}.from(hash))\n    new_time = new_time.shift(days: days_away)\n  else\n    new_time = Time.local(**{year: Int32, month: Int32, day: Int32, hour: Int32, minute: Int32, second: Int32}.from(hash))\n  end\n  if (  new_time < now)\n    shift_time_by_frequency(new_time)\n  else\n    new_time\n  end\nend\nnext_times.min\n"}}]},{"html_id":"chronos/Chronos/Task","path":"Chronos/Task.html","kind":"class","full_name":"Chronos::Task","name":"Task","abstract":true,"superclass":{"html_id":"chronos/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"chronos/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"chronos/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/chronos/task.cr","line_number":7,"url":null}],"repository_name":"chronos","program":false,"enum":false,"alias":false,"const":false,"subclasses":[{"html_id":"chronos/Chronos/OneTimeTask","kind":"class","full_name":"Chronos::OneTimeTask","name":"OneTimeTask"},{"html_id":"chronos/Chronos/PeriodicTask","kind":"class","full_name":"Chronos::PeriodicTask","name":"PeriodicTask"},{"html_id":"chronos/Chronos/RecurringTask","kind":"class","full_name":"Chronos::RecurringTask","name":"RecurringTask"}],"namespace":{"html_id":"chronos/Chronos","kind":"class","full_name":"Chronos","name":"Chronos"},"doc":"Task is the base class for different types of tasks.\n\nSubclasses all contain a block of code to be run at the specified times,\nbut have different ways of scheduling the times to run.","summary":"<p>Task is the base class for different types of tasks.</p>","instance_methods":[{"html_id":"id:String-instance-method","name":"id","doc":"Returns the unique ID for this task.","summary":"<p>Returns the unique ID for this task.</p>","abstract":false,"location":{"filename":"src/chronos/task.cr","line_number":11,"url":null},"def":{"name":"id","return_type":"String","visibility":"Public","body":"@id"}},{"html_id":"next_run:Time-instance-method","name":"next_run","doc":"Returns the next scheduled `Time` for this task to execute its block.","summary":"<p>Returns the next scheduled <code>Time</code> for this task to execute its block.</p>","abstract":true,"location":{"filename":"src/chronos/task.cr","line_number":21,"url":null},"def":{"name":"next_run","return_type":"Time","visibility":"Public","body":""}},{"html_id":"run-instance-method","name":"run","doc":"Executes the block of code specified at creation.","summary":"<p>Executes the block of code specified at creation.</p>","abstract":false,"location":{"filename":"src/chronos/task.cr","line_number":24,"url":null},"def":{"name":"run","visibility":"Public","body":"@block.call"}}]}]}]}})