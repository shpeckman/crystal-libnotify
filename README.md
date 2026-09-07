# crystal-libnotify

Crystal bindings for [libnotify](https://gitlab.gnome.org/GNOME/libnotify), the library for sending desktop notifications to a notification daemon (as defined by the [Desktop Notifications Specification](https://specifications.freedesktop.org/notification/latest/)).

## Requirements

- Crystal >= 1.21.0
- `libnotify` development headers (`libnotify-dev` on Debian/Ubuntu, `libnotify` on Arch)

The low-level C bindings in `crystal_lib/libnotify.cr` are generated with [`crystal_lib`](https://github.com/crystal-lang/crystal_lib) and link against `libnotify`.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystal-libnotify:
    github: shpeckman/crystal-libnotify
```

Then run `shards install`.

## Usage

```crystal
require "crystal-libnotify"

# Quick one-liner
Libnotify.show("Hello, world!")

# Full example
n = Libnotify.new(summary: "Backup finished", body: "All files synced.")
n.timeout = 5.0  # seconds
n.urgency = :normal
n.show

# Block style
Libnotify.show do |n|
  n.summary  = "Build complete"
  n.body     = "Your shard compiled without errors."
  n.urgency  = :low
  n.category = "build"
end
```

### Notification properties

| Property    | Type      | Default     | Notes                                                                       |
|-------------|-----------|-------------|-----------------------------------------------------------------------------|
| `summary`   | `String?` | `nil`       | Title of the notification                                                   |
| `body`      | `String?` | `nil`       | Body text                                                                   |
| `icon_path` | `String?` | `nil`       | Path to an icon image                                                       |
| `app_name`  | `String`  | `"default"` | Application name shown by the daemon                                        |
| `timeout`   | `Int32`   | `-1`        | Timeout in ms; `-1` = server default; `timeout=` accepts seconds as a float |
| `category`  | `String?` | `nil`       | Notification category                                                       |
| `urgency`   | `Symbol`  | `:normal`   | `:low`, `:normal` or `:critical`                                            |
| `append`    | `Bool`    | `false`     | Append to an existing notification                                          |
| `transient` | `Bool`    | `true`      | Not kept in the notification history                                        |

### Actions

```crystal
n = Libnotify.new("Deploy finished")
n.add_action("open", "Open dashboard") do
  puts "Opening dashboard..."
end
n.show
```

### Server information

```crystal
Libnotify.server_caps  # => ["actions", "body", "icon-static", ...]
Libnotify.server_info  # => {name: "org.freedesktop.Notifications", vendor: "GNOME", ...}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

MIT
