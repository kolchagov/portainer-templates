#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
base_file="templates_v3.json"
update_file="templates.json"
output_file="all.json"
tmp_file="${output_file}.tmp"

cd "$script_dir"

for file in "$base_file" "$update_file"; do
  if [[ ! -f "$file" ]]; then
    printf 'Required template file not found: %s\n' "$file" >&2
    exit 1
  fi

  if ! jq -e '(.templates? | type) == "array"' "$file" >/dev/null 2>&1; then
    printf 'Template file does not contain a top-level templates array: %s\n' "$file" >&2
    exit 1
  fi
done

jq -n \
  --slurpfile base "$base_file" \
  --slurpfile update "$update_file" \
  '
  def template_key:
    if (.name? // "") != "" then
      "name:" + (.name | ascii_downcase)
    elif (.title? // "") != "" then
      "title:" + (.title | ascii_downcase)
    else
      null
    end;

  def merge_templates($base_templates; $update_templates):
    reduce $update_templates[] as $item (
      $base_templates;
      ($item | template_key) as $key |
      if $key == null then
        . + [$item]
      else
        ([.[] | template_key] | index($key)) as $index |
        if $index == null then
          . + [$item]
        else
          .[$index] = $item
        end
      end
    );

  {
    version: ($base[0].version // $update[0].version // "3"),
    templates: merge_templates(($base[0].templates // []); ($update[0].templates // []))
  }
  ' > "$tmp_file"

if [[ ! -s "$tmp_file" ]]; then
  printf 'Failed to generate %s\n' "$tmp_file" >&2
  exit 1
fi

mv "$tmp_file" "$output_file"

printf 'Merged %s with updates from %s into %s\n' "$base_file" "$update_file" "$output_file"