---
name: start-mod
description: Kick off development of THIS Fabric mod from its blank skeleton — read the conventions, plan, ask scoping questions, then implement. Use when the user says "commençons le module", "start the mod", "let's build the mod/feature", or otherwise wants to begin implementing the mod's actual behaviour.
---

Onboarding protocol for starting real work on this mod. Follow the steps in order — do not skip straight to code.

1. **Read the conventions.** Open `tools/fabric-agent-kit/AGENTS.md` in full and follow it: pinned config (MC 1.21.11, official Mojang mappings, JDK 21), split client/common (`src/main` = common/server, `src/client` = client-only), and the golden rule "verify the API before writing".

2. **Plan before coding.** Enter plan mode and ask the user concise scoping questions first:
   - What should the mod do? (the core feature, in one or two sentences)
   - Server-side, client-side, or both? (server-only logic vs GUI/rendering/client networking)
   - External dependencies? (Fabric API is assumed; any Modrinth projects or other mods?)
   - Interaction surface? (commands, a GUI screen, world events, a config file)

3. **Get the plan approved**, then implement following the golden rule:
   - BEFORE writing any Minecraft/Fabric call, confirm the exact signature with `/mc-api` — these Mojang mappings differ from Yarn tutorials (e.g. `ResourceLocation` is named `Identifier`).
   - AFTER each step that compiles, run `/run-mod` to prove the mod still boots (build + headless dedicated server + asserts the mod loads).
   - Never guess a method/class name; a build that compiles does not prove runtime correctness.

4. The GUI client (`./gradlew runClient`) must be launched by a human — it cannot be driven headless. `/run-mod` covers all server-side logic.

Full conventions and the catalogue of 1.21.11 mapping gotchas: `tools/fabric-agent-kit/AGENTS.md`.
