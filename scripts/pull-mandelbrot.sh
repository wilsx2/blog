#!/usr/bin/env bash
#
# Step 1: pull LaTeX sources from a wilsx2/mandelbrot checkout into the
# Mandelbrot post directory, preserving the relative layout that the .tex
# hardcodes (./docs/bibliography.bib and ./images/).
#
# usage: pull-mandelbrot.sh <mandelbrot-source-dir>
set -euo pipefail

usage() {
  echo "usage: $0 <mandelbrot-source-dir>" >&2
  exit 1
}

SRC="${1:-}"
[ -n "$SRC" ] || usage
[ -d "$SRC" ] || { echo "error: not a directory: $SRC" >&2; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POST_DIR="$ROOT/_posts/2026-08-05-mandelbrot-set"

TEX="$SRC/docs/document.tex"
[ -f "$TEX" ] || { echo "error: missing $TEX" >&2; exit 1; }

mkdir -p "$POST_DIR/docs" "$POST_DIR/images"

echo "==> pulling $TEX"
cp "$TEX" "$POST_DIR/document.tex"

echo "==> pulling $SRC/docs/bibliography.bib"
cp "$SRC/docs/bibliography.bib" "$POST_DIR/docs/bibliography.bib"

images="$(grep -o 'includegraphics[^{]*{[^}]*\.png}' "$TEX" | sed 's/.*{\([^}]*\)}/\1/' | sort -u)"
[ -n "$images" ] || { echo "error: no images referenced in $TEX" >&2; exit 1; }

while IFS= read -r img; do
  echo "==> pulling images/$img"
  cp "$SRC/images/$img" "$POST_DIR/images/$img"
done <<< "$images"

echo "==> done"
