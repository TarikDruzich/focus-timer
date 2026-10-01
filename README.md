Work in# Focus Timer

Minimal Pomodoro-style work/break timer plugin for the Omarchy bar.

Focus Timer adds a segmented progress indicator to the Omarchy bar and provides a compact popup for timer controls, statistics, and configuration.

## Installation

Install Focus Timer directly from GitHub:

```bash
omarchy plugin add https://github.com/TarikDruzich/focus-timer.git --enable
```

If the widget is not visible automatically after installation, add **Focus Timer** to your Omarchy bar configuration.

## Uninstall

Remove Focus Timer from Omarchy:

```bash
omarchy plugin remove tarik.focus-timer
```

Focus Timer stores statistics and configuration separately in:

```text
~/.local/share/focus-timer/
```

Removing the plugin does not automatically delete this local data.

If you also want to remove all saved statistics and configuration:

```bash
rm -rf ~/.local/share/focus-timer
```

## Features

- Pomodoro-style focus timer
- Short break and long break modes
- Start / pause controls
- Reset current phase
- Skip current phase
- Segmented progress indicator in the Omarchy bar
- Configurable focus duration
- Configurable short break duration
- Configurable long break duration
- Configurable number of focus sessions before a long break
- Optional auto-start for the next phase
- Optional 5-second completion sound
- Local focus statistics
- Today statistics
- Monthly statistics
- Yearly statistics
- All-time statistics
- Persistent local configuration

## Usage

Click the segmented progress indicator in the Omarchy bar to open Focus Timer.

The popup contains three tabs:

- **POMODORO** — timer and controls
- **STATS** — focus statistics
- **CONFIG** — timer configuration

## Pomodoro

The Pomodoro tab shows:

- Remaining time
- Current phase
- Reset button
- Start / pause button
- Skip button

Focus Timer automatically switches between focus and break phases.

After the configured number of completed focus sessions, a long break is used instead of a short break.

## Statistics

Focus Timer records completed focus sessions locally.

Statistics are available for:

- Today
- This month
- This year
- All time

A focus session is counted only when it finishes naturally.

Skipped or reset sessions are not counted as completed focus sessions.

## Configuration

The **CONFIG** tab allows you to configure:

- Focus duration
- Short break duration
- Long break duration
- Number of focus sessions before a long break
- Auto-start next phase
- Completion sound

Configuration is stored locally and persists between Omarchy shell restarts.

## Completion Sound

Focus Timer includes a local WAV completion sound.

The sound is played when a focus or break session finishes naturally.

The plugin uses `pw-play` to play the included audio file.

Completion sound can be enabled or disabled from the **CONFIG** tab.

### Dependency

Completion sound playback requires `pw-play`.

Check whether it is available:

```bash
which pw-play
```

If `pw-play` is unavailable, the timer itself can still function, but completion sound playback will not work.

## Local Data

Focus Timer stores its local data in:

```text
~/.local/share/focus-timer/
```

Statistics are stored in:

```text
~/.local/share/focus-timer/stats.json
```

Configuration is stored in:

```text
~/.local/share/focus-timer/config.json
```

## Privacy

Focus Timer does not require an account.

It does not use:

- Analytics
- Telemetry
- Cloud storage
- Remote APIs
- Network access for statistics
- Network access for configuration

Statistics and configuration remain on the local machine.

## Development

Clone the repository:

```bash
git clone https://github.com/TarikDruzich/focus-timer.git
cd focus-timer
```

Validate the plugin:

```bash
omarchy plugin validate .
```

For local development, copy the plugin files:

```bash
cp Service.qml BarWidget.qml \
  ~/.config/omarchy/plugins/tarik.focus-timer/
```

Copy the sound asset:

```bash
mkdir -p ~/.config/omarchy/plugins/tarik.focus-timer/assets

cp assets/end.wav \
  ~/.config/omarchy/plugins/tarik.focus-timer/assets/
```

Restart the Omarchy shell:

```bash
omarchy-restart-shell
```

## Repository Structure

```text
focus-timer/
├── BarWidget.qml
├── Service.qml
├── manifest.json
├── README.md
├── LICENSE
└── assets/
    └── end.wav
```

## Planned Features

- Custom focus durations
- Custom short break durations
- Custom long break durations
- Additional configuration options

## Status

Focus Timer is under active development.

The current version is functional and available for testing.

## License

MIT progress.
