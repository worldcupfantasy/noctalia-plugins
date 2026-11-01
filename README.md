# noctalia-plugins

Plugins for [Noctalia](https://noctalia.dev) v5+.

Each directory is one plugin; the directory name matches the part after the
`author/` prefix in its id.

| Plugin | Id | What it does |
| --- | --- | --- |
| [media-toggle](media-toggle/) | `ech678/media-toggle` | Play/pause bar button whose glyph follows the real MPRIS state |

## Install

```sh
git clone https://github.com/worldcupfantasy/noctalia-plugins
cp -r noctalia-plugins/media-toggle ~/.local/share/noctalia/plugins/
noctalia msg plugins enable ech678/media-toggle
```

## Develop

```sh
noctalia msg plugins source add ech678 path /path/to/this/repo
```

`source add` makes the working tree load directly, so `.luau` edits hot-reload.

## License

MIT
