---
name: start-mod
description: Kick off development of THIS Fabric mod from its blank skeleton — read the conventions, plan, ask scoping questions, then implement. Use when the user says "commençons le module", "start the mod", "let's build the mod/feature", or otherwise wants to begin implementing the mod's actual behaviour.
---

This skill is a thin Claude Code handle over the **agent-agnostic onboarding protocol** that lives in
`tools/fabric-agent-kit/AGENTS.md` (section « Démarrer le développement du mod »). That file is the single
source of truth — read it in full and follow it. Summary of the protocol:

1. **Read `tools/fabric-agent-kit/AGENTS.md`** and follow it: pinned config (MC 1.21.11, Mojang mappings,
   JDK 21), split client/common, the golden rule "verify the API before writing".
2. **Plan before coding.** Ask the user the scoping questions first:
   - What should the mod do? (the core feature, in one or two sentences)
   - Server-side, client-side, or both?
   - External dependencies? (Fabric API is assumed; Modrinth projects or other mods?)
   - Interaction surface? (commands, a GUI screen, world events, a config file)
3. **Get the plan approved**, then implement applying the golden rule: `/mc-api` (→ `bin/mc-api`) BEFORE any
   Minecraft/Fabric call, `/run-mod` (→ `bin/mc-smoke`) AFTER each step that compiles. Never guess a name.
4. The GUI client (`./gradlew runClient`) must be launched by a human.

Non-Claude agents don't need this skill — they read `AGENTS.md` and call `bin/*` directly.
