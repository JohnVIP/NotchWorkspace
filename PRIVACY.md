# Privacy

Notch Workspace is local-first.

- No accounts, analytics, telemetry, or device fingerprinting.
- Everything Notch Workspace creates (settings, notes, shelf items) stays on your Mac,
  unless you choose a notes folder that syncs, such as one in iCloud Drive.
- System permissions (Calendar, Reminders, Camera, and so on) are requested only
  when you enable the feature that needs them. Denying one disables only that
  feature.
- Messages sent with the Show in Notch action or an `notchworkspace://` link are
  only displayed: they're never stored, and nothing in them is opened.
## Agent status

Agent status is off until you connect a tool in the Agents tab or in
**Settings › Agents**. Connecting adds hooks to that tool's own
settings file (`~/.claude/settings.json` for Claude Code, `~/.codex/hooks.json`
for Codex) and first keeps a copy of the file as it was in
`~/Library/Application Support/NotchWorkspace/Backups`. The hooks run a small script,
`~/Library/Application Support/NotchWorkspace/notchworkspace-agent-hook`, which writes one
file per session into `~/Library/Application Support/NotchWorkspace/Agents`: the
session's state, its project folder, the app it runs in, its process ID, and
the tool's own words for what it's waiting for. Your prompts, code, and tool
output are never written, and nothing leaves your Mac. Disconnecting removes the
hooks, and with no tool connected, the script and the session files too.

A change that weakens any of these points must say so in its pull request and
update this file.
