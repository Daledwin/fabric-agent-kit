# shellcheck shell=bash
# _jdk.sh — definit mc_find_jdk21 (echo le HOME d'un JDK 21). A SOURCER, pas a executer.
# Override : MC_JDK=/chemin/jdk21  (ou JAVA_HOME pointant deja un 21).

_mc_is_jdk21() {
  [ -x "$1/bin/javap" ] || return 1
  "$1/bin/java" -version 2>&1 | head -1 | grep -qE '"21' || return 1
}

mc_find_jdk21() {
  if [ -n "${MC_JDK:-}" ] && _mc_is_jdk21 "$MC_JDK"; then echo "$MC_JDK"; return 0; fi
  if [ -n "${JAVA_HOME:-}" ] && _mc_is_jdk21 "$JAVA_HOME"; then echo "$JAVA_HOME"; return 0; fi
  local d
  for d in "$HOME"/.jdks/* /usr/lib/jvm/* "$HOME"/.sdkman/candidates/java/* /opt/*jdk*; do
    [ -d "$d" ] && _mc_is_jdk21 "$d" && { echo "$d"; return 0; }
  done
  return 1
}
