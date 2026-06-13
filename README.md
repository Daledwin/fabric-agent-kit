# fabric-agent-kit

Boîte à outils **agent-agnostique** pour le modding Minecraft **Fabric** (MC 1.21.11, mappings Mojang, JDK 21).
Pensée pour être ajoutée en **git submodule** dans un mod (ou au niveau d'un dossier de mods), afin que
n'importe quel agent IA — ou humain — puisse builder, vérifier les API et tester un mod de façon fiable.

## Démarrer un nouveau mod (dépôt vide → submodule → génération)
Pas besoin d'une copie « standalone » du kit : on part d'un dépôt vide, on y greffe le kit en
submodule, et on génère le mod **à la racine** avec les outils du submodule.
```bash
mkdir superbloc && cd superbloc
git init -b main
git submodule add <url-de-ce-depot> tools/fabric-agent-kit
tools/fabric-agent-kit/bin/mc-new-mod superbloc hugo.brua.superbloc "Super Bloc" --dir .
tools/fabric-agent-kit/bin/mc-setup .      # configure le JDK 21 pour gradle
tools/fabric-agent-kit/bin/mc-smoke .      # build + boot serveur headless + assert
```
`mc-new-mod` accepte une cible non vide tant qu'aucun fichier généré n'existe déjà — la présence de
`.git`, `.gitmodules` ou `tools/` ne gêne pas.

### Ajouter le kit à un mod existant
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
| `bin/mc-setup [dir]` | Pose `org.gradle.java.home`=JDK21 (fini le préfixe `JAVA_HOME`) **et câble le projet pour un agent** (skills, `CLAUDE.md`, permissions). |

Rien n'est codé en dur : le **JDK 21** et les **jars remappés** sont auto-détectés. Override : `MC_JDK=/chemin/jdk21`.

## Conventions
Tout agent doit lire **[`AGENTS.md`](AGENTS.md)** : la config, la règle « vérifier avant d'écrire », et le
catalogue des pièges de mapping 1.21.11.

## Démarrage clé en main (Claude Code)
Une fois le mod généré, **un seul appel suffit** :
```bash
tools/fabric-agent-kit/bin/mc-setup .
```
`mc-setup` configure le JDK 21 **et** câble le projet (idempotent, non destructif) :
- symlinks `.claude/skills/{mc-api,run-mod,new-mod,start-mod}` → le submodule ;
- `CLAUDE.md` : pointeur vers `AGENTS.md` + protocole d'onboarding ;
- fusion des permissions dans `.claude/settings.json`.

Ensuite : ouvrir une session d'agent dans le dossier du mod et dire **« commençons le module »** (ou
`/start-mod`) → l'agent lit `AGENTS.md`, passe en **mode plan**, pose les questions de cadrage, puis code en
appliquant la règle d'or (`/mc-api` avant, `/run-mod` après). Pour ne configurer que le JDK : `mc-setup . --no-claude`.

Les autres agents n'ont besoin de rien de tout ça — ils appellent directement `bin/*` et lisent `AGENTS.md`.

## Origine
Extrait des patterns réels d'une session de création d'un mod Fabric (`login`) : ~10 vérifs d'API par `javap`,
le footgun JDK 17/21, et le boot serveur headless qui a révélé un bug runtime invisible au build.
