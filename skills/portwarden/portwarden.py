#!/usr/bin/env python3
"""portwarden — local dev port registry, collision checker, and Caddy bridge.

Bundled with the `portwarden` Claude skill. Keeps a JSON registry of
app -> port claims under ~/.portwarden/ and reconciles it against the ports
actually LISTENing (via lsof). Optionally emits a Caddyfile so each app is
reachable at <app>.<tld> (default .localhost) with no port in the URL.

No privileges required for the registry. Caddy needs root only to *bind*
80/443 the first time it starts; per-app changes reload unprivileged.
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime

HOME = os.path.expanduser("~")
DIR = os.path.join(HOME, ".portwarden")
REGISTRY = os.path.join(DIR, "registry.json")
CADDYFILE = os.path.join(DIR, "Caddyfile")
DEFAULT_TLD = "localhost"


# ---------------------------------------------------------------- registry io
def load():
    if not os.path.exists(REGISTRY):
        return {"version": 1, "tld": DEFAULT_TLD, "apps": {}}
    with open(REGISTRY) as f:
        return json.load(f)


def save(data):
    os.makedirs(DIR, exist_ok=True)
    tmp = REGISTRY + ".tmp"
    with open(tmp, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    os.replace(tmp, REGISTRY)


# ------------------------------------------------------------ observed state
def listening():
    """Return {port:int -> {command, pid, user, addr}} for LISTEN sockets."""
    if not shutil.which("lsof"):
        return {}
    out = subprocess.run(
        ["lsof", "-nP", "-iTCP", "-sTCP:LISTEN"],
        capture_output=True, text=True, check=False,
    ).stdout
    res = {}
    for line in out.splitlines()[1:]:  # skip header
        parts = line.split()
        if len(parts) < 9:
            continue
        command, pid, user, addr = parts[0], parts[1], parts[2], parts[8]
        m = re.search(r":(\d+)$", addr)
        if not m:
            continue
        port = int(m.group(1))
        # First writer wins; prefer a concrete address over a wildcard later.
        res.setdefault(port, {"command": command, "pid": pid,
                              "user": user, "addr": addr})
    return res


def port_owner_in_registry(data, port, ignore=None):
    for name, info in data["apps"].items():
        if name != ignore and info["port"] == port:
            return name
    return None


# ------------------------------------------------------------------- output
def emit(obj, as_json):
    if as_json:
        print(json.dumps(obj, indent=2))
    return obj


# ----------------------------------------------------------------- commands
def cmd_list(args):
    data = load()
    live = listening()
    rows = []
    for name, info in sorted(data["apps"].items(), key=lambda kv: kv[1]["port"]):
        port = info["port"]
        rows.append({
            "app": name,
            "port": port,
            "live": port in live,
            "url": f"{name}.{data['tld']}",
            "note": info.get("note", ""),
        })
    registered_ports = {i["port"] for i in data["apps"].values()}
    untracked = [
        {"port": p, "command": v["command"], "pid": v["pid"], "addr": v["addr"]}
        for p, v in sorted(live.items())
        if p not in registered_ports
    ]
    if args.json:
        return emit({"tld": data["tld"], "apps": rows, "untracked": untracked}, True)
    if not rows and not untracked:
        print("No registered apps and nothing listening.")
        return
    if rows:
        print("REGISTERED")
        for r in rows:
            flag = "● live" if r["live"] else "○ idle"
            note = f"  — {r['note']}" if r["note"] else ""
            print(f"  {r['port']:>5}  {flag}  {r['app']}  ({r['url']}){note}")
    if untracked:
        print("\nUNTRACKED LISTENERS (in use, not registered)")
        for u in untracked:
            print(f"  {u['port']:>5}  {u['command']} (pid {u['pid']})  {u['addr']}")


def cmd_register(args):
    data = load()
    port = args.port
    if not (1 <= port <= 65535):
        print(f"error: port {port} out of range (1-65535)", file=sys.stderr)
        return 2
    clash = port_owner_in_registry(data, port, ignore=args.app)
    if clash:
        print(f"error: port {port} already registered to '{clash}'", file=sys.stderr)
        return 2
    if args.app in data["apps"] and not args.force:
        cur = data["apps"][args.app]["port"]
        print(f"error: '{args.app}' already registered on port {cur} "
              f"(use --force to move it)", file=sys.stderr)
        return 2
    live = listening()
    entry = {"port": port, "registered_at": datetime.now().isoformat(timespec="seconds")}
    if args.note:
        entry["note"] = args.note
    data["apps"][args.app] = entry
    save(data)
    url = f"{args.app}.{data['tld']}"
    warn = ""
    if port in live and live[port]["command"] not in ("", None):
        warn = f"  (note: port {port} is already in use by {live[port]['command']})"
    print(f"registered {args.app} -> {port}  ({url}){warn}")


def cmd_deregister(args):
    data = load()
    target = args.target
    name = None
    if target in data["apps"]:
        name = target
    elif target.isdigit():
        name = port_owner_in_registry(data, int(target))
    if not name:
        print(f"error: nothing registered matching '{target}'", file=sys.stderr)
        return 2
    port = data["apps"].pop(name)["port"]
    save(data)
    print(f"deregistered {name} (was port {port})")


def cmd_check(args):
    data = load()
    port = args.port
    live = listening()
    owner = port_owner_in_registry(data, port)
    in_use = port in live
    result = {
        "port": port,
        "free": not (owner or in_use),
        "registered_to": owner,
        "listening": live.get(port),
    }
    if args.json:
        emit(result, True)
    else:
        if result["free"]:
            print(f"port {port}: FREE")
        else:
            bits = []
            if owner:
                bits.append(f"registered to '{owner}'")
            if in_use:
                l = live[port]
                bits.append(f"in use by {l['command']} (pid {l['pid']}, {l['addr']})")
            print(f"port {port}: TAKEN — {'; '.join(bits)}")
    return 0 if result["free"] else 1


def cmd_free(args):
    data = load()
    taken = set(listening().keys()) | {i["port"] for i in data["apps"].values()}
    port = args.start
    while port <= 65535:
        if port not in taken:
            print(port)
            return 0
        port += 1
    print("error: no free port found", file=sys.stderr)
    return 2


def cmd_caddy(args):
    data = load()
    # Always emit a valid Caddyfile — an explicit admin block keeps the file
    # valid (and the reload target predictable) even with zero apps, so the
    # always-on service starts cleanly before anything is registered.
    lines = [
        "# Generated by portwarden — do not edit by hand.",
        "# Regenerate with: portwarden caddy",
        "{",
        "\tadmin localhost:2019",
        "}",
        "",
    ]
    for name, info in sorted(data["apps"].items(), key=lambda kv: kv[1]["port"]):
        lines.append(f"{name}.{data['tld']} {{")
        lines.append(f"\treverse_proxy localhost:{info['port']}")
        lines.append("}")
        lines.append("")
    with open(CADDYFILE, "w") as f:
        f.write("\n".join(lines))
    n = len(data["apps"])
    print(f"wrote {CADDYFILE} ({n} app{'' if n == 1 else 's'})")
    # Try an unprivileged hot reload if Caddy's admin API is up.
    if shutil.which("caddy"):
        r = subprocess.run(
            ["caddy", "reload", "--config", CADDYFILE, "--adapter", "caddyfile"],
            capture_output=True, text=True, check=False,
        )
        if r.returncode == 0:
            print("reloaded running Caddy")
        else:
            print("Caddy not running yet (changes apply when the service starts).")


def main():
    p = argparse.ArgumentParser(prog="portwarden", description=__doc__.splitlines()[0])
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("list", help="show registered apps + untracked listeners")
    s.add_argument("--json", action="store_true")
    s.set_defaults(func=cmd_list)

    s = sub.add_parser("register", help="claim a port for an app")
    s.add_argument("app")
    s.add_argument("port", type=int)
    s.add_argument("--note")
    s.add_argument("--force", action="store_true", help="move an existing app")
    s.set_defaults(func=cmd_register)

    s = sub.add_parser("deregister", help="release a claim by app name or port")
    s.add_argument("target")
    s.set_defaults(func=cmd_deregister)

    s = sub.add_parser("check", help="is a port free? exit 0=free, 1=taken")
    s.add_argument("port", type=int)
    s.add_argument("--json", action="store_true")
    s.set_defaults(func=cmd_check)

    s = sub.add_parser("free", help="print the next free port")
    s.add_argument("--start", type=int, default=3000)
    s.set_defaults(func=cmd_free)

    s = sub.add_parser("caddy", help="generate Caddyfile for clean .localhost URLs")
    s.set_defaults(func=cmd_caddy)

    args = p.parse_args()
    sys.exit(args.func(args) or 0)


if __name__ == "__main__":
    main()
