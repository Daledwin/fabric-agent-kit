---
name: run-mod
description: Build a Fabric mod with JDK 21 and smoke-test it by booting a headless dedicated server and asserting the mod loads. Use to run, build, test, verify, or smoke-test the mod after changes.
---

Wrapper for the kit's `bin/mc-smoke`. Adjust the path to where the submodule is mounted (e.g. `tools/fabric-agent-kit/`).

```bash
tools/fabric-agent-kit/bin/mc-smoke [project-dir] [--marker <regex>]
```

What it does: builds with JDK 21 (offline) → boots the dedicated server headless → waits for `Done (` → asserts the mod's id (from `fabric.mod.json`) appears in the log and that there are no load errors → sends `stop`. Exit 0 = **PASS**. Server log: `/tmp/mc-smoke-server.log`.

The GUI client (`./gradlew runClient`) must be launched by a human — it's an OpenGL window and can't be driven headless. `mc-smoke` covers all server-side logic (events, commands, networking registration, mod init). Full conventions: `tools/fabric-agent-kit/AGENTS.md`.
