#!/usr/bin/env bash

files=()
while IFS= read -r -d '' f; do
  files+=("$f")
done < <(find . \( -name '*.yml' -o -name '*.yaml' \) -print0 | sort -z)

if [ ${#files[@]} -gt 0 ]; then
  dclint --fix "${files[@]}"
fi
