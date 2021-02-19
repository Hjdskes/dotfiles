#!/usr/bin/env bash

if ! hash readlink 2>/dev/null; then
  printf "%s needs readlink to be available" "$0"
fi

for f in ./.*; do
  [[ -f "$f" ]] && ln -sf "$(readlink -f $f)" ~/
done
