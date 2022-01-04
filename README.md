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

By default, any errors raised inside a task are logged to STDERR without any interruption of the scheduler. However, this behaviour can be modified.

If you wish the scheduler to propagate the error, then you can set #raise_on_error to be true:

```crystal
scheduler.raise_on_error
```

You can also modify the source of the logged error messages:

```crystal
scheduler.stderr = File.new("logs/errors.txt", 'w')
```

Lastly, it's possible to enter a custom callback using #on_raise:

```crystal
scheduler.on_raise do |ex|
  puts "ERROR: #{Time.now} #{ex.message}"
end
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/HCLarsen/chronos/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris Larsen](https://github.com/HCLarsen) - creator and maintainer
