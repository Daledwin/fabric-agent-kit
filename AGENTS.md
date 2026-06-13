# AGENTS.md — Conventions modding Minecraft Fabric (config BLOOM-AI)

Doc destinée à **tout agent** (et tout humain) qui touche à un mod Fabric ici. Outils dans `bin/` (voir `README.md`).

## La config (ne pas en dévier)
- Minecraft **1.21.11**, **Fabric** (loader + Fabric API), **mappings Mojang officiels**, **JDK 21**.
- Le `java` système peut être plus ancien → les builds doivent tourner sous JDK 21
  (`bin/mc-setup` pose `org.gradle.java.home` une fois pour toutes).
- Projet **split client/common** : `src/main` = code commun/**serveur**, `src/client` = code **client only**
  (écrans/GUI, rendu, réseau côté client). Du code client appelé dans `src/main` peut **crasher le serveur**.

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
