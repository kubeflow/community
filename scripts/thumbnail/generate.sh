#!/bin/bash
set -e

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <date> <group> <meeting>"
  echo "        $0 \"2026/01/08\" \"Kubeflow Community\" \"Kubeflow Community Call\""
  exit 1
fi

DATE="${1}"
GROUP="${2}"
MEETING="${3}"
OUTPUT="thumbnail_${GROUP// /_}_$(date -d "$DATE" "+%Y-%m-%d").png"

typst compile "$(dirname "$0")/thumbnail.typ" "$OUTPUT" \
    --input date="$(date -d "$DATE" "+%B %d, %Y")" \
    --input group="$(printf '%s\n' "$GROUP" | awk '{ print toupper($0) }')" \
    --input title="$MEETING"

echo "Generated: $OUTPUT"
