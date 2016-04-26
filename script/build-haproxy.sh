#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

declare -r HAPROXY=haproxy-1.6.3
declare -r LUA=lua-5.3.2
declare -r SHA256SUMS='
fd06b45054cde2c69cb3322dfdd8a4bcfc46eb9d0c4b36d20d3ea19d84e338a7  haproxy-1.6.3.tar.gz
c740c7bb23a936944e1cc63b7c3c5351a8976d7867c5252c8854f7b2af9da68f  lua-5.3.2.tar.gz
'

log() {
  printf "=> %s\n" "${@}"
}

die() {
  printf "%s\n" "${@}" >&2
  exit 1
}

mkdir -p ext
cd ext

[[ -f "${LUA}.tar.gz" ]] && \
  log 'already downloaded Lua source' || \
  { 
    log 'downloading Lua source';
    curl -fsLRS -O "http://www.lua.org/ftp/${LUA}.tar.gz";
  }

[[ -f "${HAPROXY}.tar.gz" ]] && \
  log 'already downloaded HAProxy source' || \
  {
    log 'downloading HAProxy source';
    curl -fsLRS -O "http://www.haproxy.org/download/1.6/src/${HAPROXY}.tar.gz";
  }

log 'verifying SHA256 checksums'
sha256sum -c - <<<"${SHA256SUMS}"

log 'unpacking Lua'
tar -xzf "${LUA}.tar.gz"
log 'building Lua'
(cd "${LUA}" && make generic && make local)

log 'unpacking HAProxy'
tar -xzf "${HAPROXY}.tar.gz"
log 'building HAProxy'
(cd "${HAPROXY}" && make TARGET=generic USE_LUA=yes LUA_LIB="../${LUA}/install/lib/" LUA_INC="../${LUA}/install/include/")

log "start HAProxy with ./ext/${HAPROXY}/haproxy [OPTIONS...]"
