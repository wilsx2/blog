#!/usr/bin/env bash
#
# Step 2: rebuild every Jekyll post directory that contains a .tex source
# for MathJax, using the same TeX4ht pipeline as the local build:
#   make4ht <tex> "mathjax"  ->  biber <tex>  ->  make4ht <tex> "mathjax" x2
#
# For each post directory:
#   - builds in a scratch dir (so the committed ./docs and ./images resolve),
#   - extracts the body fragment (first sectionHead h3 through the closing
#     </dl> of the bibliography), dropping the TeX4ht head and \maketitle,
#   - retargets citation links that point at the dropped document.html,
#   - preserves existing front matter (or generates it for a new post),
#   - writes <post-dir>/<post-dir-name>.html, copies document.css, and prunes
#     stale document*.png and TeX4ht build artifacts.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POSTS_DIR="$ROOT/_posts"

ARTIFACTS=".4ct .4tc .aux .bbl .bcf .blg .dvi .idv .lg .log .mk4 .run.xml .tmp .xref"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "error: required command '$1' not found" >&2; exit 1; }
}

extract_front_matter() {
  awk '/^---$/ { n++ } n <= 2 { print } n == 2 && /^---$/ { exit }'
}

generate_front_matter() {
  local post_dir="$1"
  local tex="$2"
  local title
  title="$(sed -n 's/.*\\title{\([^}]*\)}.*/\1/p' "$tex" | head -n 1)"
  local datepart
  datepart="$(basename "$post_dir" | sed -E 's/^([0-9]{4}-[0-9]{1,2}-[0-9]{1,2})-.*/\1/')"
  cat <<EOF
---
layout: post
title: ${title:-$(basename "$post_dir")}
date: $datepart
---
EOF
}

prune_artifacts() {
  local dir="$1"
  rm -f "$dir"/document*.png
  local ext
  for ext in $ARTIFACTS; do
    rm -f "$dir/$ext"
  done
}

build_post() {
  local post_dir="$1"
  local tex_files=("$post_dir"/*.tex)
  if [ ! -e "${tex_files[0]}" ]; then
    echo "==> skip $post_dir (no .tex)"
    return 0
  fi

  local tex="${tex_files[0]}"
  local base
  base="$(basename "$tex" .tex)"
  local post_name
  post_name="$(basename "$post_dir").html"
  local post_html="$post_dir/$post_name"

  echo "==> build $post_dir from $(basename "$tex")"

  local scratch
  scratch="$(mktemp -d)"
  trap 'rm -rf "$scratch"' RETURN

  cp -r "$post_dir"/. "$scratch"/

  (
    cd "$scratch" \
      && make4ht "$base.tex" "mathjax" >/dev/null 2>&1 \
      && (biber "$base" >/dev/null 2>&1 || true) \
      && make4ht "$base.tex" "mathjax" >/dev/null 2>&1 \
      && make4ht "$base.tex" "mathjax" >/dev/null 2>&1
  )

  local built="$scratch/$base.html"
  [ -f "$built" ] || { echo "error: make4ht produced no $built" >&2; return 1; }

  local frag
  frag="$(mktemp)"
  trap 'rm -f "$frag"; rm -rf "$scratch"' RETURN

  awk '
    /<h3 class=.?sectionHead/ { start = 1 }
    start {
      lines[n++] = $0
      if ($0 ~ /<\/dl>/) last = n
    }
    END {
      if (last == 0) last = n
      for (i = 0; i < last; i++) print lines[i]
    }
  ' "$built" > "$frag"

  sed -i \
    -e "s/href='document\.html#/href='#/g" \
    -e "s/href='document\.html'/href='#'/g" \
    "$frag"

  local front
  if [ -f "$post_html" ] && grep -q '^---$' "$post_html"; then
    front="$(extract_front_matter < "$post_html")"
    front="${front:-$(generate_front_matter "$post_dir" "$tex")}"
  else
    front="$(generate_front_matter "$post_dir" "$tex")"
  fi

  {
    printf '%s\n' "$front"
    printf "\n<link href='document.css' rel='stylesheet' type='text/css' />\n\n"
    cat "$frag"
  } > "$post_html.tmp"
  mv "$post_html.tmp" "$post_html"

  cp "$scratch/$base.css" "$post_dir/$base.css"
  prune_artifacts "$post_dir"

  echo "==> wrote $post_html"
}

require_cmd make4ht
require_cmd biber

shopt -s nullglob
for post_dir in "$POSTS_DIR"/*/; do
  [ -d "$post_dir" ] || continue
  build_post "$post_dir"
done
shopt -u nullglob

echo "==> done"
