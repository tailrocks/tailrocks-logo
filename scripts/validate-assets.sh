#!/usr/bin/env bash
set -euo pipefail

repository_root="$(git rev-parse --show-toplevel)"
cd "$repository_root"

temporary_directory="$(mktemp -d)"
trap 'rm -rf "$temporary_directory"' EXIT

tracked_file_count=0
validated_artwork_count=0

while IFS= read -r -d '' path; do
  tracked_file_count=$((tracked_file_count + 1))
  if [[ ! -s "$path" ]]; then
    printf 'Tracked file is empty: %s\n' "$path" >&2
    exit 1
  fi

  extension="${path##*.}"
  extension="$(printf '%s' "$extension" | tr '[:upper:]' '[:lower:]')"

  case "$extension" in
    ai)
      pdfinfo "$path" >/dev/null
      pdftoppm -f 1 -l 1 -r 1 -singlefile -q "$path" "$temporary_directory/$tracked_file_count"
      test -s "$temporary_directory/$tracked_file_count.ppm"
      validated_artwork_count=$((validated_artwork_count + 1))
      ;;
    eps)
      gs -q -dNOPAUSE -dBATCH -sDEVICE=nullpage "$path"
      validated_artwork_count=$((validated_artwork_count + 1))
      ;;
    jpg|jpeg|png|psd)
      if command -v magick >/dev/null 2>&1; then
        magick "${path}[0]" null:
      elif command -v convert >/dev/null 2>&1; then
        convert "${path}[0]" null:
      else
        printf 'ImageMagick is required to decode %s\n' "$path" >&2
        exit 1
      fi
      validated_artwork_count=$((validated_artwork_count + 1))
      ;;
    svg)
      xmllint --nonet --noout "$path"
      rsvg-convert "$path" --output "$temporary_directory/$tracked_file_count.png"
      test -s "$temporary_directory/$tracked_file_count.png"
      validated_artwork_count=$((validated_artwork_count + 1))
      ;;
    ttf)
      font_family="$(fc-scan --format '%{family}' "$path")"
      if [[ -z "$font_family" ]]; then
        printf 'Font has no readable family name: %s\n' "$path" >&2
        exit 1
      fi
      validated_artwork_count=$((validated_artwork_count + 1))
      ;;
    yaml|yml)
      yamllint --strict -d relaxed "$path"
      ;;
    sh)
      bash -n "$path"
      ;;
    gitignore|md|txt)
      iconv -f UTF-8 -t UTF-8 "$path" >/dev/null
      ;;
    *)
      printf 'Unsupported tracked file type (%s): %s\n' "$extension" "$path" >&2
      exit 1
      ;;
  esac
done < <(git ls-files -z)

if (( tracked_file_count == 0 || validated_artwork_count == 0 )); then
  printf 'Expected tracked logo assets, found %d files and %d artwork assets\n' \
    "$tracked_file_count" "$validated_artwork_count" >&2
  exit 1
fi

printf 'Validated %d tracked files, including %d artwork assets.\n' \
  "$tracked_file_count" "$validated_artwork_count"
