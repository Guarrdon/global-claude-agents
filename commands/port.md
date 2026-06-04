---
description: Force the portwarden skill — manage local dev ports (list/free/register/check/deregister/caddy)
argument-hint: "[list | free | register <app> <port> | check <port> | deregister <app|port> | caddy]"
---

Invoke the **portwarden** skill to handle a local development port request.

Arguments: $ARGUMENTS

Fulfill it with the bundled tool at `~/.claude/skills/portwarden/portwarden.py`:

- **No arguments** → run `list` (registered apps + untracked listeners).
- **A subcommand** (`list`, `free [--start N]`, `register <app> <port> [--note "..."] [--force]`, `check <port>`, `deregister <app|port>`, `caddy`) → pass it straight through.
- **Natural language** (e.g. "what's eating 8080", "grab me a port for the dashboard") → translate intent to the right subcommand(s). Prefer `free` then `register` over guessing a port.

Confirm before any destructive change (`deregister`). Report results concisely, and surface the owner on any collision.
