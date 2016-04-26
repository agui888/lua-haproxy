#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname $(dirname "${BASH_SOURCE[0]}"))/src"

lua ../script/soar.lua -a -s main.lua | cut -f1 | grep -Ev '(_main|binary dependencies)' | sort

rm -f soar.out
