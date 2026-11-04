<p align="center">
  <img src="docs/media/icon.png" width="128" alt="The upstream ILoveNotch icon: a notch with heart eyes">
</p>

<h1 align="center">Notch Workspace</h1>

<p align="center"><b>Your MacBook's notch, finally useful.</b> Free and open source.</p>

<p align="center">
  <a href="https://github.com/JohnVIP/NotchWorkspace/actions/workflows/ci.yml"><img src="https://github.com/JohnVIP/NotchWorkspace/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="License: MIT"></a>
  <a href="#build--run"><img src="https://img.shields.io/badge/macOS-14.6%2B-black?logo=apple" alt="macOS 14.6 or later"></a>
  <a href="https://github.com/sponsors/niyamvora"><img src="https://img.shields.io/badge/sponsor-%E2%9D%A4-db61a2?logo=githubsponsors&logoColor=white" alt="Sponsor"></a>
</p>

A personal macOS fork of [ILoveNotch](https://github.com/niyamvora/ILoveNotch) — turns the notch on Apple
Silicon MacBooks into an interactive tray for files, calendars,
tasks, notes, shortcuts, timers, and coding agent status.
Built with SwiftUI and AppKit.

<p align="center">
  <img src="docs/media/screenshots/shelf.png" width="49%" alt="Park it in the notch: files dropped on the notch shelf, ready to drag out or AirDrop">
  <img src="docs/media/screenshots/timer.png" width="49%" alt="Focus in one tap: preset timers from 1 minute to 1 hour, plus a stopwatch">
  <img src="docs/media/screenshots/calendar.png" width="49%" alt="Your day, one hover away: today's events in the notch">
</p>

> **Not affiliated with, endorsed by, or derived from any commercial notch app.**
> This is a clean-room implementation written from scratch. It contains no
> disassembled or decompiled code, and nothing from any commercial notch app.
> Features are common-idea reimplementations. Everything here is original or
> comes from permissively licensed open-source projects (MIT, BSD, CC0), listed
> in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## What it does

- **The notch.** Opens when you hover it, click it, pull down with two fingers,
  or press ⌃⌥W in any app, and closes when you move away. Closed, it hides
  behind the camera housing until it has something to tell you, like a meeting
  about to start. Pick how it opens and closes (spring, jelly, pop, smooth,
  snappy, or instant), drag its bottom-right corner to resize it, and pin it
  open. The grid button after the tabs opens every app in a drawer, like
  Launchpad: click one to open it, and the grid button takes you back. The
  drawer's Edit tile (or a right-click on the tabs) lets you drag the tabs into
  your own order and keep the ones you use less in the drawer, right in the
  notch. On macOS 26, open it in Liquid Glass instead of black. Works on every
  display: where there's no notch, it draws one inside the menu bar, or a
  floating pill if you'd rather.
- **Shelf.** Drop files on the notch to keep them at hand; drag them back out,
  preview them with Quick Look, or send them with AirDrop.
- **Calendar and Tasks.** Today's events with the tasks due today, an event
  field that understands "Lunch tomorrow 1pm", and your own events to edit or
  delete right in the notch. A Join button for Zoom,
  Google Meet, Teams, Webex, Whereby, Jitsi, and FaceTime calls, and a
  countdown in the closed notch for the five minutes before one starts. Your
  Apple Reminders, grouped by date or list, synced to your iPhone through
  iCloud: add them in plain words ("Pay rent fri 9am !! #Home"), set dates,
  priorities, lists, and alerts, block time for one in Calendar, and see it on
  the notch when it's due.
- **Notes, Shortcuts, and Timer.** Markdown notes that save as you type, with
  colors, pins, search, checklists you can send to Tasks, and a
  Control-Option-N shortcut; your shortcuts one click away; a timer and a
  stopwatch with laps; and Keep Awake, which stops your Mac sleeping for a
  while or until you turn it off, with the time left in the closed notch.
- **Agents.** When Claude Code or Codex needs your approval, the closed notch
  says so until you answer, and it tells you when one finishes while you're in
  another app; one click takes you back to its terminal.
  [More below](#agent-status).
- **System activities.** Volume, charging and battery, and Bluetooth accessory
  batteries show briefly in the notch.
- **Show in Notch.** A Shortcuts action and an `notchworkspace://` link put your own
  message in the notch, from any shortcut, automation, script, or app.
  [More below](#show-in-notch).
- **Settings.** Laid out like System Settings: a sidebar with a page for each
  part of the app and each tab, marked with colored icons, and each tab's
  switch at the top of its page. The notch's gear button or the menu bar item
  opens it.
## Why

Notch utilities are genuinely useful, but the popular closed-source one drew
complaints about heavy RAM/CPU use, and in September 2026 its license server
went offline, so paid licenses stopped working. ILoveNotch is a free, efficient
alternative with nothing to switch off: no license, no account, no server, and
code anyone can inspect, build, and improve.

## Efficiency

The upstream build was measured over a real 20-hour workday on an Apple M5 Pro MacBook (24 GB, macOS
26.6.2), 24–25 September 2026.

<p align="center">
  <img src="docs/media/efficiency/barely-there.png" width="49%" alt="Barely there: 0.45% of the Mac's total energy over a 20-hour workday, 0.0% CPU at rest, never kept the Mac awake or woke it, and 77 MB of memory, flat">
  <img src="docs/media/efficiency/energy.png" width="49%" alt="Used less energy than Finder: 0.45% of the Mac's energy, about 100 times less than VS Code and 34 times less than Chrome, 13th of 47 apps and services">
  <img src="docs/media/efficiency/wakeups.png" width="49%" alt="150 times fewer CPU wakeups than Chrome: 1,502, against 224,112 for Chrome and 525,651 for VS Code, and 2 minutes 49 seconds of CPU time in 20 hours">
  <img src="docs/media/efficiency/sleep.png" width="49%" alt="Never keeps your Mac awake: no sleep-blocking requests and no wakes over 20 hours and 4 lid-closed sleeps">
  <img src="docs/media/efficiency/memory.png" width="49%" alt="Memory stayed flat over 20 hours: about 77 MB in active use from hour 15 to hour 20, most of it the 30-day Claude usage history and the interface">
  <img src="docs/media/efficiency/peak-memory.png" width="49%" alt="Up to 95% less peak memory reading AI usage logs: 120 MB down to 6 MB for an 80 MB log, and 223 MB down to 20 MB for the 8 largest logs">
</p>

## Design principles (the efficiency story)

1. **No polling timers.** State changes come from events (hover, clicks, system
   notifications). The only timers are one-shot deadlines, like the hover dwell,
   cancelled the moment they stop mattering.
2. **Accessory app.** No Dock icon (`LSUIElement`), one small menu bar item for
   Settings and Quit, and the notch never steals focus (`nonactivatingPanel`).
3. **Lazy features.** Each feature module is `stopped`, `background` (cheap
   event observers only), or `foreground` (on screen). Hidden tabs cost nothing.
4. **Native, no Electron/webview.** Pure SwiftUI/AppKit.
5. **Measured, not assumed.** Signposts on every event, performance tests in CI,
   and an Instruments pass per feature against the
   [performance budgets](docs/plan/implementation-plan.md#8-performance-gates).

## Architecture

```text
hover, clicks, drags, sleep/lock, display changes
  → NotchEvent
  → NotchState.handle(_:)   pure reducer: next state + effects
  → NotchEngine             one per display: runs deadline timers
  → FeatureHost             runs each feature at the highest phase any display asks for
  → NotchView               one animatable notch shape inside a fixed panel
```

| Module | Role |
|--------|------|
| `App/` | App target generated from `project.yml`: wires features in, menu bar item, Settings |
| `NotchCore` | State machine, `NotchEngine`, `FeatureHost` lifecycle, preferences, typed logging and signposts. No AppKit. |
| `NotchSurface` | Fixed click-through `NSPanel` per display, animatable `NotchShape`, `PanelCoordinator` (displays, sleep, lock), notch geometry from **public** APIs (`safeAreaInsets`, `auxiliaryTop*Area`), and the tab row's editor (`TabEditor`) and app drawer (`AppDrawer`) |
| `NotchFeatures` | Feature modules (Shelf, Calendar, Tasks, Notes, Shortcuts, Timer), each a `NotchFeature` with its views and settings, and the event-driven system monitors and hooks (volume, battery, accessories, keyboard shortcuts, Show in Notch) |
| `NotchAgents` | The GitHub build’s Claude Code and Codex status and hooks |
| `Tests/` | Unit tests (reducer transitions and fuzzing, engine, feature host, preferences, geometry, features), offscreen snapshot tests, XCTest performance tests |

The full design is in the [implementation plan](docs/plan/implementation-plan.md)
and the [architecture diagram](docs/plan/architecture.html).

## Build & run

The project targets macOS 14.6 and uses Swift tools 6.2, an Xcode SDK with macOS 26 APIs, and XcodeGen. From a checkout of this fork:

```bash
make build SIGNING_IDENTITY=
make check-isolation SIGNING_IDENTITY=
make test
```

The local build is `.build/xcode/Build/Products/Debug/NotchWorkspace.app`. `make run` opens it from the build directory. See [runtime isolation](docs/updates.md) for the identity, local paths, and rollback.

```bash
log stream --level debug --predicate 'subsystem == "io.github.johnvip.notchworkspace"'
```

## Agent status

The Agents tab shows what Claude Code and Codex are doing in your terminals:
working, finished, or waiting for you to approve something. While one waits,
the closed notch shows a raised hand and the project until you answer, and when
one finishes while its app is in the background, the notch says so. **Go**
brings its terminal forward.

Nothing is connected until you connect it, in the tab or in **Settings ›
Agents**. Connecting adds hooks to the tool's own settings
(`~/.claude/settings.json`, or `~/.codex/hooks.json`, which Codex asks you to
trust the next time it starts), next to any hooks already there, and
disconnecting takes out exactly those. The hooks run in the background, so an
agent never waits on them, and they write one small file per session: its
state, project folder, terminal app, and what it's waiting for, never your
prompts or code. Nothing leaves your Mac; see [PRIVACY.md](PRIVACY.md#agent-status).

## Show in Notch

Shortcuts has a **Show in Notch** action, with a message, an SF Symbol, and how
many seconds to show it, so any shortcut or automation can put a message in the
notch. Scripts and other apps can open a link instead:

```bash
open -g "notchworkspace://show?title=Build%20done&symbol=hammer.fill&seconds=5"
```

A message shows for 1 to 30 seconds (4 by default) and is never stored. It's
only ever displayed: links in it aren't opened, line breaks and control
characters are removed, and it's cut to 80 characters.

## Tasks and notes

Tasks use Apple **Reminders** through EventKit, so they sync to your iPhone over
iCloud with no server to run, and alerts set in the notch ring on every device.
Notes are Markdown files named after their first line, in
`~/Library/Application Support/NotchWorkspace/Notes` by default. To read them on an
iPhone, pick a folder in iCloud Drive in Settings › Notes: they show
up in the Files app and in Markdown apps such as Obsidian. A note's color and
pin are kept in a small front matter block those apps understand, and a file you
named yourself keeps its name when you edit it in the notch. The Share button
sends a copy to Apple Notes; driving Apple Notes directly through Apple Events
was dropped as brittle and permission-heavy. (Google **Keep** is intentionally
not used: it has no official API.) Calendar and Reminders access is requested
only when you tap **Continue** in their tab.

## Contributing

Questions and ideas go in [Discussions](https://github.com/niyamvora/ILoveNotch/discussions);
bugs and feature requests in [Issues](https://github.com/niyamvora/ILoveNotch/issues/new/choose).
See [CONTRIBUTING.md](CONTRIBUTING.md). Report vulnerabilities privately as
described in [SECURITY.md](SECURITY.md); privacy commitments are in
[PRIVACY.md](PRIVACY.md).

## Sponsors

ILoveNotch is free and open source. If it's useful to you,
[sponsor the project](https://github.com/sponsors/niyamvora) to help keep it
maintained, and star the repo so more people find it.

<!-- ponytail: add a tiered logo table here (like chanhdai.com's README) once there are sponsors -->

## License

MIT — see [LICENSE](LICENSE).
