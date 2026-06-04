---
name: portwarden
description: >-
  Manage local development ports. Use when the user asks what's running on a
  port, wants to claim/register or release a port for an app, hits or wants to
  avoid a port collision, asks for a free/available port to start a dev server,
  or wants clean <app>.localhost URLs (no :port) via Caddy. Backed by a JSON
  registry at ~/.portwarden/ reconciled against actually-listening ports.
---

# portwarden

A local dev port registry + collision checker, with an optional Caddy bridge for
clean `<app>.localhost` URLs. All state lives in `~/.portwarden/`. The registry
needs no privileges; only the one-time Caddy start binds 80/443 and needs sudo.

## The tool

A single self-contained script ships with this skill. Always call it by its
absolute path:

```
python3 ~/.claude/skills/portwarden/portwarden.py <command> [args]
```

### Commands

| Command | What it does |
|---|---|
| `list [--json]` | Registered apps (with live/idle status) **and** untracked listeners |
| `register <app> <port> [--note "..."] [--force]` | Claim a port; fails on registry collision; `--force` moves an existing app |
| `deregister <app|port>` | Release a claim by app name or by port number |
| `check <port> [--json]` | Is the port free? Exit code **0 = free, 1 = taken** |
| `free [--start 3000]` | Print the next free port (registry- and lsof-aware) |
| `caddy` | (Re)generate `~/.portwarden/Caddyfile` and hot-reload a running Caddy |

`check` is scriptable via its exit code; everything supports `--json` where a
machine-readable answer is useful.

## How to use it

- **"What's on port 3000 / what's running?"** → `list`, or `check 3000` for one port.
- **"Give me a free port for X."** → `free`, then `register X <that-port>`.
- **"Register/claim port N for app X."** → `register X N`. If it reports a
  collision, surface the owner and offer `free` to pick another, or `--force`
  if they're deliberately moving an app.
- **"This installed app uses port N"** (databases, vendor tools not actively
  developed) → `register` it too, so the registry reflects reality. The `--note`
  field is good for "not actively developed, installed via brew", etc.
- **"Stop tracking X" / "free up that port"** → `deregister`.

Prefer `free` + `register` over guessing a port. Treat the registry as intent
and `lsof` as reality — `list` shows both so drift is visible.

## Clean URLs (Caddy, optional)

`.localhost` names resolve to `127.0.0.1` for free in browsers, but the **port**
still has to come from somewhere — Caddy on :80/:443 routes `<app>.localhost`
to the registered backend port so the URL needs no `:port`.

1. After registering apps, run `caddy` to (re)generate the Caddyfile.
2. **One-time, privileged** (the user must run this themselves — it binds 80/443):
   ```
   sudo caddy start --config ~/.portwarden/Caddyfile --adapter caddyfile
   ```
   Suggest they type it with a leading `!` so it runs in-session.
3. After that, every `caddy` regen hot-reloads **without** sudo (Caddy's admin
   API is local). So registering a new app + `caddy` is enough to make
   `https://<app>.localhost` live.

Without Caddy, `<app>.localhost:<port>` still works with zero setup — the name
resolves free, you just keep the port in the URL.

## Notes

- macOS: `.local` is hijacked by mDNS/Bonjour — never use it. `.localhost` is the
  default and needs no hosts-file edits. Don't touch `/etc/hosts` for this.
- The registry is intentionally machine-local (ports differ per box).
- Scope stays tight on purpose: list / register / deregister / check / free /
  caddy. No hosts-file management, no daemons beyond the optional Caddy.
