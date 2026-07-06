#!/usr/bin/env bash
set -euo pipefail

URL="https://myanimelist.net/animelist/tachikomaki?status=2&order=4&order2=0"
OUTPUT_PATH="${1:-assets/anime_ranking.json}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_FILE="${REPO_ROOT}/${OUTPUT_PATH}"
else
  OUTPUT_FILE="$OUTPUT_PATH"
fi

TMP_HTML="$(mktemp)"
trap 'rm -f "$TMP_HTML"' EXIT

curl -L -A 'Mozilla/5.0' -s "$URL" > "$TMP_HTML"

python3 - "$TMP_HTML" "$OUTPUT_FILE" <<'PY'
import html
import json
import os
import re
import sys
from urllib.parse import urljoin

html_path, output_path = sys.argv[1], sys.argv[2]

with open(html_path, 'r', encoding='utf-8', errors='ignore') as handle:
    content = handle.read()

match = re.search(r'<table[^>]*class="list-table"[^>]*data-items="([^"]*)"', content)
if not match:
    raise SystemExit('Could not find list-table data-items markup')

raw_items = html.unescape(match.group(1))
items = json.loads(raw_items)

existing_entries = []
if os.path.exists(output_path):
    with open(output_path, 'r', encoding='utf-8') as handle:
        try:
            existing_data = json.load(handle)
        except json.JSONDecodeError:
            existing_data = []
        if isinstance(existing_data, list):
            existing_entries = existing_data

existing_by_id = {}
for entry in existing_entries:
    if isinstance(entry, dict) and entry.get('anime_id') is not None:
        existing_by_id[entry['anime_id']] = entry

for item in items:
    anime_id = item.get('anime_id')
    if anime_id is None:
        continue

    normalized = {
        'title': item.get('anime_title') or item.get('title_localized') or '',
        'score': item.get('score'),
        'anime_url': urljoin('https://myanimelist.net', item.get('anime_url', '')),
        'image_url': item.get('anime_image_path') or '',
        'anime_id': anime_id,
    }

    if anime_id in existing_by_id:
        existing_entry = existing_by_id[anime_id]
        if normalized['score'] is not None:
            existing_entry['score'] = normalized['score']
        if not existing_entry.get('title'):
            existing_entry['title'] = normalized['title']
        if not existing_entry.get('anime_url'):
            existing_entry['anime_url'] = normalized['anime_url']
        if not existing_entry.get('image_url'):
            existing_entry['image_url'] = normalized['image_url']
        if existing_entry.get('anime_id') is None:
            existing_entry['anime_id'] = anime_id
    else:
        existing_entries.append(normalized)
        existing_by_id[anime_id] = existing_entries[-1]

with open(output_path, 'w', encoding='utf-8') as handle:
    json.dump(existing_entries, handle, ensure_ascii=False, indent=2)
    handle.write('\n')
PY

echo "Wrote ${OUTPUT_FILE}"
