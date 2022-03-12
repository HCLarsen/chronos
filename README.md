# Chronos

Crystal scheduling system.

**WARNING** This shard is not ready for use yet.

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  chronos:
    github: HCLarsen/chronos
```

2. Run `shards install`

## Usage

```crystal
require "chronos"

scheduler = Chronos.new

scheduler.in("5m") do
  # do something in 5 minutes
end

scheduler.at("01/07/2022 0:00:00") do
  # do something at this specific point in time.
end

scheduler.every("1h") do
  # do something every hour
end

scheduler.every("1h", "01/07/2022 0:00:00") do
  # do something every hour starting at midnight on January 7th, 2022
end

scheduler.every(:day, "08:30:00") do
  # do something at 8:30AM every day
end

scheduler.run
```

Tasks can be added to and deleted from the scheduler while running, without any interruption to execution.

### Time Zones

The scheduler defaults to Time::Location.local for scheduling recurring events. This can be changed by setting the time zone in either the initializer, or after the fact.

```crystal
scheduler = Chronos.new(Time::Location.utc)

scheduler.location = Time::Location.local
```

### Error Handling

Unhandled exceptions raised when executing a task are logged to a [`Log`](https://crystal-lang.org/api/latest/Log.html) object.

```
2022-01-11 19:25:10 -05:00 [chronos/2452] Info: RuntimeError - Random error
```

A default log is created when a `Chronos` instance is initialized, but you can also set it to a custom logger.

```crystal
scheduler.log = Log.for("custom logger")
```

## Development

All new features/modifications, must be properly tested. Any PRs without passing tests will not be merged.

Features to be added:

1. Move task execution into separate fibre.
2. Time string parsing for Chronos methods.

## Contributing

1. Fork it (<https://github.com/HCLarsen/chronos/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris Larsen](https://github.com/HCLarsen) - creator and maintainer
