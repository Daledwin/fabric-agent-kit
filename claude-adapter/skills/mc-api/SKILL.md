---
name: mc-api
description: Look up exact Mojang-mapped Minecraft/Fabric API signatures (for this project's MC version) via javap. Use before writing any Minecraft/Fabric code, or when unsure of a method name, signature, return type, or whether a class exists in these mappings.
---

Wrapper for the kit's `bin/mc-api`. Adjust the path to where the submodule is mounted (e.g. `tools/fabric-agent-kit/`).

```bash
tools/fabric-agent-kit/bin/mc-api <fully.qualified.ClassName> [grep-regex] [--client|--common|--module <name>]
```

Examples:

```bash
tools/fabric-agent-kit/bin/mc-api net.minecraft.server.level.ServerPlayer 'setGameMode|teleportTo'
tools/fabric-agent-kit/bin/mc-api net.minecraft.client.gui.components.EditBox addFormatter --client
tools/fabric-agent-kit/bin/mc-api net.fabricmc.fabric.api.networking.v1.ServerPlayNetworking register --module networking-api-v1
```

Auto-detects JDK 21 and the remapped jars in the Gradle/loom cache. **Always verify an API here before writing code** — these Mojang mappings differ from Yarn tutorials (e.g. `ResourceLocation` is named `Identifier`). Full conventions: `tools/fabric-agent-kit/AGENTS.md`.
