# Architecture

```text
CityMarks/
├── CityMarks.toc
├── Locale.lua
├── Locales/
│   ├── enUS.lua
│   ├── zhCN.lua
│   └── zhTW.lua
├── Data.lua
├── Core.lua
├── Map.lua
├── Settings.lua
├── tests/
│   └── smoke.lua
└── docs/
    └── architecture.md
```

- `Locale.lua`: Locale registration and English fallback handling.
- `Locales/`: One text file per supported language.
- `Data.lua`: Supported cities and static service coordinates.
- `Core.lua`: Saved-variable defaults, profession detection, and startup.
- `Map.lua`: Map rendering, grouping, filtering, and map controls.
- `Settings.lua`: Native Blizzard AddOns settings panel.
- `tests/smoke.lua`: Minimal mocked WoW runtime smoke test.

`Data.lua` contains no UI logic. `Map.lua` reads data and configuration but does
not own saved-variable initialization. `Settings.lua` mutates configuration
through the shared addon namespace and requests a map refresh.

The addon uses a small file-based design because each responsibility has one
consumer boundary and no external libraries are required.

## Changelog

- 1.0.3: Fixed settings labels for the WoW 12.0.7 radio-button template.
- 1.0.2: Fixed settings slash commands and improved map-label contrast.
- 1.0.1: Split localization strings into one file per language.
- 1.0.0: Initial independent implementation for WoW 12.0.7.
