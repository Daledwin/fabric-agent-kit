---
name: new-mod
description: Scaffold a new, correctly-configured Fabric mod project (MC 1.21.11, Mojang mappings, split client/common) offline in one command. Use to create, generate, scaffold, or start a new Minecraft Fabric mod.
---

Wrapper for the kit's `bin/mc-new-mod`. Adjust the path to where the submodule is mounted (e.g. `tools/fabric-agent-kit/`).

```bash
tools/fabric-agent-kit/bin/mc-new-mod <mod-id> <package> ["Display Name"] [--dir <target>]
```

Example:

```bash
tools/fabric-agent-kit/bin/mc-new-mod superbloc hugo.brua.superbloc "Super Bloc"
```

Generates **offline** a skeleton that compiles and runs (ModInitializer in `src/main`, ClientModInitializer in `src/client`, `fabric.mod.json`, mixin configs, gradle build) — no web template generator needed. Pinned config: MC 1.21.11, official Mojang mappings, split client/common, JDK 21. After generating, open it in IntelliJ or run `bin/mc-smoke <dir>` to verify. See `tools/fabric-agent-kit/AGENTS.md`.
