# fabric-agent-kit

Boîte à outils **agent-agnostique** pour le modding Minecraft **Fabric** (MC 1.21.11, mappings Mojang, JDK 21).
Pensée pour être ajoutée en **git submodule** dans un mod (ou au niveau d'un dossier de mods), afin que
n'importe quel agent IA — ou humain — puisse builder, vérifier les API et tester un mod de façon fiable.

## Ajouter en submodule
```bash
git submodule add <url-de-ce-depot> tools/fabric-agent-kit
tools/fabric-agent-kit/bin/mc-setup        # configure le JDK 21 pour gradle
```

## Les outils (`bin/`)
| Script | Rôle |
|---|---|
| `bin/mc-new-mod <mod-id> <package> ["Nom"]` | Génère un **nouveau mod** pré-configuré (1.21.11, Mojang, split client/common) hors-ligne — remplace le générateur web. |
| `bin/mc-api <FQN> [grep] [--client\|--module <m>]` | Signatures Mojang exactes via `javap` (cache loom, JDK 21). **À utiliser AVANT d'écrire du code.** |
| `bin/mc-smoke [dir] [--marker <re>]` | Build JDK21 + boot serveur dédié headless + assert que le mod charge + stop. |
| `bin/mc-setup [dir]` | Pose `org.gradle.java.home`=JDK21 (fini le préfixe `JAVA_HOME`) + imprime l'intégration Claude. |

Rien n'est codé en dur : le **JDK 21** et les **jars remappés** sont auto-détectés. Override : `MC_JDK=/chemin/jdk21`.

## Conventions
Tout agent doit lire **[`AGENTS.md`](AGENTS.md)** : la config, la règle « vérifier avant d'écrire », et le
catalogue des pièges de mapping 1.21.11.

## Claude Code (optionnel)
`claude-adapter/` fournit deux skills fins (`/mc-api`, `/run-mod`) + un snippet de permissions. Pour les
activer dans un projet hôte, copier ou symlinker `claude-adapter/skills/*` sous son `.claude/skills/`.
Rien de tout ça n'est requis pour les autres agents — ils appellent directement `bin/*`.

## Origine
Extrait des patterns réels d'une session de création d'un mod Fabric (`login`) : ~10 vérifs d'API par `javap`,
le footgun JDK 17/21, et le boot serveur headless qui a révélé un bug runtime invisible au build.
