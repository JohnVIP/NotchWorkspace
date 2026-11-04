# Privacy

ILoveNotch is local-first.

- No accounts, analytics, telemetry, or device fingerprinting.
- The app uses the network to check for updates against GitHub Releases.
- Everything ILoveNotch creates (settings, notes, shelf items) stays on your Mac,
  unless you choose a notes folder that syncs, such as one in iCloud Drive.
- System permissions (Calendar, Reminders, Camera, and so on) are requested only
  when you enable the feature that needs them. Denying one disables only that
  feature.
- The Mirror tab is off until you turn it on, and uses the camera only while
  that tab is open. Nothing is recorded or saved.
- Replacing the macOS volume display is off until you turn it on. It asks for
  Accessibility access to catch the volume keys; ILoveNotch takes only the three
  volume keys and passes every other event through untouched.
- The Network tab sends nothing. It reads how many bytes your Mac's network
  interfaces have moved, never what the bytes were, where they went, or which
  app moved them, and keeps the totals by the hour in
  `~/Library/Application Support/OpenNotch/network.sqlite` on this Mac only.
  The first time it runs, it reads NetSpeed's history from
  `~/Library/Application Support/NetSpeed` if it's there. **Clear History** in
  Settings › Network deletes it, and turning the tab off stops counting.
- Messages sent with the Show in Notch action or an `ilovenotch://` link are
  only displayed: they're never stored, and nothing in them is opened.
- Clipboard history is off until you turn it on in the Clipboard tab. Then it
  keeps what you copy (text, links, images, and file locations) in
  `~/Library/Application Support/OpenNotch` on this Mac only, up to 200 items
  plus your favorites. It skips anything the copying app marks secret or
  temporary and anything copied in a password manager. **Clear History**
  removes everything but favorites, and turning it off stops reading the
  clipboard.
- To move the media waveform with the music, ILoveNotch listens to your Mac's
  audio output, and macOS asks for "system audio recording" permission the first
  time. It listens only while the Media tab is open and something plays, turns
  the sound into loudness per frequency band as it plays, and never records,
  stores, or sends audio. Turn it off in Settings › Media.
- Shuffle, repeat, Music's up next and lyrics, Spotify's recently played, and,
  in the App Store edition, all of Media's controls talk to Music or Spotify
  through their own AppleScript, on this Mac. macOS asks first (Privacy &
  Security › Automation), the first time you press one of those buttons, and
  ILoveNotch only ever talks to the app that's playing. Spotify's recently
  played list is kept in memory and gone when ILoveNotch quits.

## Agent status

Agent status is off until you connect a tool in the Agents tab or in
**Settings › Agents**. Connecting adds hooks to that tool's own
settings file (`~/.claude/settings.json` for Claude Code, `~/.codex/hooks.json`
for Codex) and first keeps a copy of the file as it was in
`~/Library/Application Support/OpenNotch/Backups`. The hooks run a small script,
`~/Library/Application Support/OpenNotch/ilovenotch-agent-hook`, which writes one
file per session into `~/Library/Application Support/OpenNotch/Agents`: the
session's state, its project folder, the app it runs in, its process ID, and
the tool's own words for what it's waiting for. Your prompts, code, and tool
output are never written, and nothing leaves your Mac. Disconnecting removes the
hooks, and with no tool connected, the script and the session files too.

A change that weakens any of these points must say so in its pull request and
update this file.
