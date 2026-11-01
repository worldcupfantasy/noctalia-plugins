# Media Toggle for Noctalia

A bar button that actually knows what the player is doing.

Noctalia's built-in `custom_button` carries a fixed glyph, so a pause that comes
from a hardware key, a player window or a phone leaves the icon showing the wrong
state. This widget streams `playerctl --follow status` and swaps the glyph the
moment the state changes.

## Behaviour

- Playing → `media-pause`
- Paused / stopped → `media-play`
- No active player → hidden
- Left click → `playerctl play-pause`, with the glyph flipping before the
  command returns so the press feels instant
- A 5-second poll stays as a fallback for when no player existed at load time

### Why the icon never bounces

The first version flipped the glyph on click, then immediately asked
`playerctl status`. That answer usually arrived *before* the player had finished
changing state, so the icon snapped back to the old glyph and only then settled.
A periodic poll could win the same race. Both paths are now closed:

- no poll runs inside the click handler; only the follow stream may correct it
- poll results issued before a newer stream event are discarded
- poll results landing within 1.2 s of a click are discarded
- a single failed `playerctl` call no longer hides the widget (three in a row do)

## Requirements

- Noctalia v5+ (plugin API 43)
- `playerctl` in `PATH`

## Install

```sh
mkdir -p ~/.local/share/noctalia/plugins
git clone https://github.com/worldcupfantasy/noctalia-plugins /tmp/noctalia-plugins
cp -r /tmp/noctalia-plugins/media-toggle ~/.local/share/noctalia/plugins/
noctalia msg plugins enable ech678/media-toggle
```

Then point a bar widget at it:

```toml
[widget.mediatoggle]
type = "ech678/media-toggle:toggle"
```

```sh
noctalia msg config-set widget.mediatoggle.type '"ech678/media-toggle:toggle"'
```

Put it next to the media widget, or group both into one capsule:

```toml
[[bar.bar.capsule_group]]
id = "g2"
members = ["media", "mediatoggle"]
enabled = true
fill = "surface_container"
foreground = "secondary"
border = "outline_variant"
opacity = 0.79
padding = 10.0
radius = 80.0
widget_spacing = 6
```

```sh
noctalia msg config-set bar.bar.end '["group:g2", "volume", "tray", "notifications", "session"]'
```

## Development

Drop the repository next to your config and register it as a path source, so
edits hot-reload instead of needing a copy step:

```sh
noctalia msg plugins source add ech678 path /path/to/noctalia-plugins
noctalia msg plugins enable ech678/media-toggle
```

## License

MIT
