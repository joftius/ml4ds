#!/usr/bin/env bash
# ST310 site: import a delivery folder from Dropbox, render, check, deploy.
# Lives at _build_env/build.sh inside the ml4ds repo clone, ~/work/teaching/ml4ds (outside Dropbox and iCloud).
#
#   _build_env/build.sh import <delivery-folder>      copy sources in (rsync; skips root-level *.md such as CHANGES.md)
#   _build_env/build.sh student                       regenerate every weeks/*/notebooks/notebookN.qmd from instructor/.../notebookN_complete.qmd
#   _build_env/build.sh instructor                    render instructor material -> instructor/_rendered/ (decks with notes, teacher notes, board scripts, complete notebooks)
#   _build_env/build.sh site                          clean public render -> docs/, restore CNAME
#   _build_env/build.sh check                         gates; non-zero exit on any failure
#   _build_env/build.sh push "<commit message>"       check, then git add/commit/push
#   _build_env/build.sh deploy <delivery-folder> "<commit message>"    import, student, instructor, site, check, push
#
# WEEK=02 _build_env/build.sh instructor    restricts the instructor renders to weeks/02-*/ (they are the slow step).
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)

import() {
  local src="${1:?delivery folder required}"
  [ -d "$src" ] || { echo "no such folder: $src"; exit 1; }
  rsync -av --exclude='/*.md' --exclude='.DS_Store' "$src/" "$ROOT/"
}

student() {
  local c w s
  for c in instructor/weeks/*/notebooks/*_complete.qmd; do
    [ -e "$c" ] || continue
    w=$(basename "$(dirname "$(dirname "$c")")")
    s="weeks/$w/notebooks/$(basename "${c%_complete.qmd}").qmd"
    mkdir -p "$(dirname "$s")"
    python3 _build_env/make_incomplete.py "$c" "$s"
  done
}

instructor() {
  local d f out dest
  mkdir -p instructor/_rendered
  # Decks with speaker notes kept, self-contained. A single-file render inside a
  # Quarto project lands under docs/, so each is moved out immediately.
  for d in weeks/${WEEK:-*}/slides/*.qmd; do
    [ -e "$d" ] || continue
    ST310_KEEP_NOTES=1 quarto render "$d" -M embed-resources:true
    out="docs/${d%.qmd}.html"
    dest="instructor/_rendered/${d%.qmd}-instructor.html"
    mkdir -p "$(dirname "$dest")"
    mv "$out" "$dest"
  done
  # Teacher notes, board scripts, complete notebooks (all formats in their YAML).
  for f in instructor/weeks/${WEEK:-*}/*.qmd instructor/weeks/${WEEK:-*}/notebooks/*_complete.qmd; do
    [ -e "$f" ] || continue
    quarto render "$f" -M embed-resources:true
  done
  # Their output lands under docs/instructor/ (project output-dir) or, if Quarto
  # treats them as outside the project, beside the source. Move either out.
  if [ -d docs/instructor ]; then
    rsync -a docs/instructor/ instructor/_rendered/
    rm -rf docs/instructor
  fi
  find instructor/weeks \( -name '*.html' -o -name '*.pdf' \) -print0 |
    while IFS= read -r -d '' f; do
      dest="instructor/_rendered/${f#instructor/}"
      mkdir -p "$(dirname "$dest")"
      mv "$f" "$dest"
    done
  echo "instructor renders in instructor/_rendered/"
}

site() {
  rm -rf docs _freeze .quarto
  quarto render
  echo "ml4ds.com" > docs/CNAME
  mkdir -p docs/decks-notes
  find instructor/_rendered -name "*-instructor.html" -exec cp {} docs/decks-notes/ \;
}

check() {
  local fail=0 n s
  n=$(find docs -name '*_complete*' | wc -l | tr -d ' ')
  [ "$n" -eq 0 ] || { echo "FAIL: _complete files under docs/"; fail=1; }
  [ ! -e docs/instructor ] || { echo "FAIL: docs/instructor/ exists"; fail=1; }
  if grep -rlq 'Reveal answer\|Reveal solution' docs; then echo "FAIL: answer boxes in docs/"; fail=1; fi
  if grep -rlq --exclude-dir=decks-notes 'class="notes"' docs --include='*.html'; then echo "FAIL: speaker notes in docs/"; fail=1; fi
  [ "$(cat docs/CNAME 2>/dev/null)" = "ml4ds.com" ] || { echo "FAIL: docs/CNAME"; fail=1; }
  grep -q '^instructor/$' .gitignore || { echo "FAIL: instructor/ not in .gitignore"; fail=1; }
  n=$(git ls-files | grep -c '^instructor/' || true)
  [ "$n" -eq 0 ] || { echo "FAIL: instructor files tracked by git"; fail=1; }
  for s in weeks/*/notebooks/notebook*.qmd; do
    [ -e "$s" ] || continue
    [ -e "docs/$s" ] || { echo "FAIL: $s not in docs/ (check the resources: pattern in _quarto.yml)"; fail=1; }
  done
  if grep -lq '\.answer' weeks/*/notebooks/*.qmd 2>/dev/null; then echo "FAIL: .answer div in a student notebook"; fail=1; fi
  # style warnings, not failures
  grep -rn --include="*.qmd" -e "—" weeks instructor/weeks | cut -c1-200 | head -40 || true
  grep -rniw --include="*.qmd" -e "exam" weeks index.qmd about.qmd | cut -c1-200 | head -40 || true
  if [ "$fail" -eq 0 ]; then echo "checks passed"; fi
  return "$fail"
}

push() {
  local msg="${1:?commit message required}"
  check
  git add -A
  git commit -m "$msg"
  git push origin main
}

deploy() {
  import "${1:?delivery folder required}"
  student
  instructor
  site
  push "${2:?commit message required}"
}

cmd="${1:-}"; shift || true
case "$cmd" in
  import|student|instructor|site|check|push|deploy) "$cmd" "$@" ;;
  *) sed -n '2,13p' "$0"; exit 1 ;;
esac
