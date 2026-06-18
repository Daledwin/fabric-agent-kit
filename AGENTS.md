# AGENTS.md — Conventions modding Minecraft Fabric (config BLOOM-AI)

Doc destinée à **tout agent** (et tout humain) qui touche à un mod Fabric ici. Outils dans `bin/` (voir `README.md`).

## La config (ne pas en dévier)
- Minecraft **1.21.11**, **Fabric** (loader + Fabric API), **mappings Mojang officiels**, **JDK 21**.
- Le `java` système peut être plus ancien → les builds doivent tourner sous JDK 21
  (`bin/mc-setup` pose `org.gradle.java.home` une fois pour toutes).
- Projet **split client/common** : `src/main` = code commun/**serveur**, `src/client` = code **client only**
  (écrans/GUI, rendu, réseau côté client). Du code client appelé dans `src/main` peut **crasher le serveur**.
- **Pseudo de dev par développeur** : `runClient` se lance avec un pseudo hors-ligne par défaut égal à
  ton **login OS** (chaque dev a le sien, rien de personnel commité). Override : `-PmcDevUsername=<nom>`
  ou `mcDevUsername=<nom>` dans ton `~/.gradle/gradle.properties` perso. C'est du dev (offline, sans compte
  payant) — ça n'autorise pas à *jouer* sans licence, juste à développer/tester le mod.

## Règle d'or : vérifier l'API AVANT d'écrire
Les mappings Mojang 1.21.11 **diffèrent** des tutos Yarn et de la mémoire des modèles. Avant d'écrire un
appel Minecraft/Fabric, confirme la signature exacte :
```bash
bin/mc-api net.minecraft.server.level.ServerPlayer 'setGameMode|teleportTo'
bin/mc-api net.minecraft.client.gui.components.EditBox addFormatter --client
bin/mc-api net.fabricmc.fabric.api.networking.v1.ServerPlayNetworking register --module networking-api-v1
```
Ne JAMAIS deviner un nom de méthode/classe. Et un build qui compile **ne prouve pas** que c'est correct au
runtime (cf. `createType` ci-dessous) → toujours finir par `bin/mc-smoke`.

## Démarrer le développement du mod (protocole d'onboarding)
Quand l'utilisateur dit « **commençons le module** » / « start the mod » (sous Claude Code : `/start-mod`),
applique ce protocole — **ne saute pas directement au code** :
1. **Lis ce fichier en entier** et respecte-le (config épinglée, split client/serveur, règle d'or ci-dessus).
2. **Cadre avant de coder.** Pose à l'utilisateur les questions de cadrage :
   - Que doit faire le mod ? (la fonctionnalité centrale, en une ou deux phrases)
   - **Serveur**, **client**, ou les deux ? (logique serveur vs GUI/rendu/réseau client)
   - Dépendances ? (Fabric API est acquis ; des projets Modrinth ou d'autres mods ?)
   - Surface d'interaction ? (commandes, écran GUI, events monde, fichier de config)
3. **Propose un plan court** et fais-le valider avant d'écrire du code.
4. **Code en appliquant la règle d'or** : `bin/mc-api` AVANT chaque appel Minecraft/Fabric, `bin/mc-smoke`
   APRÈS chaque étape qui compile. Ne devine jamais un nom de méthode/classe.

Ce protocole est **agent-agnostique** (il vit ici, pas dans un fichier propre à un agent). Les slash-commands
`/mc-api`, `/run-mod`, `/start-mod` ne sont qu'un confort Claude Code par-dessus `bin/*`.

## Créer un nouveau mod
```bash
bin/mc-new-mod <mod-id> <package> ["Nom"]   # ex: bin/mc-new-mod superbloc hugo.brua.superbloc "Super Bloc"
```
Génère **hors-ligne** un squelette pré-configuré (1.21.11, mappings Mojang, split client/common) qui compile
et tourne — plus besoin du générateur web. Ensuite : ouvrir dans IntelliJ, ou `bin/mc-smoke <dir>` pour vérifier.

Flux **dépôt vide → submodule → génération** (pas de copie standalone du kit) :
```bash
mkdir superbloc && cd superbloc && git init -b main
git submodule add <url-du-kit> tools/fabric-agent-kit
tools/fabric-agent-kit/bin/mc-new-mod superbloc hugo.brua.superbloc "Super Bloc" --dir .
```
`--dir .` est accepté même si la cible contient déjà `.git`, `.gitmodules` ou `tools/` : la génération ne
refuse que si un fichier qu'elle écrirait (build.gradle, src/, gradlew…) existe déjà.

## Build & run
```bash
bin/mc-setup            # une fois : configure le JDK 21 pour gradle (et IntelliJ)
bin/mc-smoke .          # build + boot serveur dédié headless + assert que le mod charge + stop
```
Le **client** (`./gradlew runClient`) doit être lancé par un humain : GUI OpenGL, non pilotable en headless.

## Catalogue des pièges 1.21.11 (vécus)
- **`Identifier`, pas `ResourceLocation`** : `net.minecraft.resources.Identifier` (`fromNamespaceAndPath`, `parse`).
- **`CustomPacketPayload.createType("ns:path")`** prend l'argument comme **chemin seul** (namespace `minecraft`)
  → `IdentifierException` au boot. Utiliser `new CustomPacketPayload.Type<>(Identifier.fromNamespaceAndPath("modid","path"))`.
- **Réseau** : payloads = records `implements CustomPacketPayload` ; codecs `StreamCodec.composite/unit` +
  `ByteBufCodecs.STRING_UTF8/BOOL` ; enregistrement `PayloadTypeRegistry.playC2S()/playS2C()` (commun) ;
  receivers `ServerPlayNetworking` (commun) / `ClientPlayNetworking` (client, package `…api.client.networking.v1`) ;
  pousser au client : `ServerPlayNetworking.canSend(player, TYPE)` puis `send(...)`.
- **GUI** : `Screen.keyPressed(net.minecraft.client.input.KeyEvent)` (plus `(int,int,int)`) → `event.key()` (code GLFW) ;
  masquer un champ : `EditBox.addFormatter((txt,i) -> FormattedCharSequence.forward("*".repeat(txt.length()), Style.EMPTY))`.
- **GUI — fond/flou (refonte rendu 1.21.11)** : dans un `Screen` custom, **NE PAS** appeler `renderBackground(...)` dans
  `render()`. Le moteur (`Screen.renderWithTooltipAndSubtitles`) appelle déjà `renderBackground` **avant** `render()`,
  et `Screen.render()` ne dessine que les widgets. Un appel manuel = 2ᵉ flou → crash runtime
  `IllegalStateException: Can only blur once per frame` (`GuiRenderState.blurBeforeThisStratum`). Override `render()`
  = `super.render(g,mx,my,dt)` (widgets) **puis** ton texte ; le fond est déjà géré. (Compile sans erreur → seul le
  runtime/`runClient` l'attrape.)
- **GUI — couleurs de texte = ARGB alpha plein** : `GuiGraphics.drawString/drawCenteredString(...,int color)` ne force
  **plus** l'opacité en 1.21.11. Une couleur RGB sans alpha (ex. `0xFFFFFF` = `0x00FFFFFF`, alpha `0x00`) est rendue
  **totalement transparente** → texte invisible (boutons OK, mais aucun label/titre ne s'affiche). Toujours passer
  `0xFF......` (ex. `0xFFFFFFFF` blanc, `0xFFFF6B6B` rouge). Compile sans erreur → bug visuel runtime seulement.
- **Joueur** : `player.gameMode()` (lit le `GameType`), `setGameMode(GameType)`, `teleportTo(d,d,d)`,
  `getUUID()`, `getName().getString()`, `player.level().getServer()`. En restaurant un gamemode : si le joueur
  était DÉJÀ spectateur, retomber sur `server.getDefaultGameType()` (sinon il reste coincé).

## Déploiement
Le mod **dépend de Fabric API** → sur le serveur, déposer `fabric-api.jar` **à côté** du mod dans `mods/`
(sinon `HARD_DEP_NO_CANDIDATE` au boot). Serveur itzg/minecraft-server : `MODRINTH_PROJECTS=fabric-api`
télécharge la dépendance tout seul. Un mod 100 % serveur n'a pas besoin d'être installé côté client ; s'il a
une UI cliente, le client doit l'avoir aussi (prévoir un fallback commande pour les clients vanilla).

## Revue
Avant un déploiement sérieux : lancer une revue adversariale (`/code-review ultra` sous Claude, ou équivalent)
qui re-vérifie le code contre les **vrais jars** — elle a déjà attrapé de vrais bugs (gamemode spectateur,
double-submit, etc.).
