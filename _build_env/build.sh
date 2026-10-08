#!/usr/bin/env bash
# ST310 site: render, check, publish. Lives at _build_env/build.sh in the ml4ds repository.
#
# The usual flow (from 7 October 2026): work on a branch of the fork, then
#   WEEK=03-classification-causality _build_env/build.sh build
# and commit everything it changed, docs/ and _freeze/ included. Merging the pull request publishes.
#
#   _build_env/build.sh build                         student, instructor, solutions, site, check (WEEK=<folder> limits the instructor and solutions renders)
#   _build_env/build.sh import <delivery-folder>      copy sources in (rsync; skips root-level *.md such as CHANGES.md)
#   _build_env/build.sh student                       regenerate every weeks/*/notebooks/notebookN.qmd from instructor/.../notebookN_complete.qmd
#   _build_env/build.sh instructor                    render instructor material -> instructor/_rendered/ (decks with notes, teacher notes, complete notebooks)
#   _build_env/build.sh solutions                     for each week whose block on the course page links to it: generate the notebook with
#                                                     solutions from the complete notebook and render it -> instructor/_rendered/solutions/
#   _build_env/build.sh site                          public render -> docs/ (unchanged pages come from _freeze/), teacher pages kept
#                                                     (decks with notes -> docs/decks-notes/; complete notebooks and teacher notes -> docs/seminar-teachers/;
#                                                     released notebooks with solutions -> docs/solutions/)
#   _build_env/build.sh check                         gates; non-zero exit on any failure
#   _build_env/build.sh push "<commit message>"       check, then git add/commit/push the current branch
#   _build_env/build.sh deploy <delivery-folder> "<commit message>"    import, student, instructor, site, check, push (Dropbox fallback)
#
# WEEK=02-regression restricts the instructor renders to that week's folder. They always execute their code, so
# rendering a week you did not change rewrites its teacher pages for nothing.
# _freeze/ is committed: a full site render re-executes only the pages whose source changed.
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
  # Start empty: site copies every teacher page it finds here, and a render left over from
  # another branch or an earlier source would be published as if it were current.
  rm -rf instructor/_rendered
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
    quarto render "$f" --embed-resources
  done
  # Their output lands under docs/instructor/ (project output-dir) or, if Quarto
  # treats them as outside the project, beside the source. Move either out.
  if [ -d docs/instructor ]; then
    cp -R docs/instructor/. instructor/_rendered/
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

# A week's notebook with solutions is released when the week's block on the course page links to it.
# $1 is the week folder, $2 the notebook's base name (notebookN).
released() {
  grep -q "solutions/$2_solutions.html" "weeks/$1/_index.qmd" 2>/dev/null
}

# The notebook with solutions is what students get the week after the seminar. It is a separate
# document from the teacher's complete notebook (convenor, 8 October 2026), generated from it and
# made only for a released week, so nothing for students exists before its link does.
solutions() {
  local c w base s out
  rm -rf instructor/_rendered/solutions
  mkdir -p instructor/_rendered/solutions
  for c in instructor/weeks/${WEEK:-*}/notebooks/*_complete.qmd; do
    [ -e "$c" ] || continue
    w=$(basename "$(dirname "$(dirname "$c")")")
    base=$(basename "${c%_complete.qmd}")
    released "$w" "$base" || continue
    s="${c%_complete.qmd}_solutions.qmd"
    python3 _build_env/make_incomplete.py --solutions "$c" "$s"
    quarto render "$s" --embed-resources
    # The output is under docs/ (project output-dir) or beside the source.
    out="${s%.qmd}.html"
    if [ -e "docs/$out" ]; then
      mv "docs/$out" instructor/_rendered/solutions/
    elif [ -e "$out" ]; then
      mv "$out" instructor/_rendered/solutions/
    else
      echo "RENDER FAILED: no output found for $s"; exit 1
    fi
    # The generated source and what its render leaves beside it are not kept.
    rm -rf "$s" "${s%.qmd}_cache" "${s%.qmd}_files"
  done
  rm -rf docs/instructor
  echo "notebooks with solutions in instructor/_rendered/solutions/"
}

site() {
  local keep d c w base f
  # The teacher pages of weeks not re-rendered this time exist only in docs/: keep them across the clean render.
  keep=$(mktemp -d)
  for d in decks-notes seminar-teachers solutions; do
    [ -d "docs/$d" ] && mv "docs/$d" "$keep/$d"
  done
  rm -rf docs .quarto
  quarto render
  echo "ml4ds.com" > docs/CNAME
  touch docs/.nojekyll
  # Quarto stamps each sitemap entry with its source file's modification time, which in a fresh
  # clone is the clone time: every branch would rewrite every line and no two would merge.
  if [ -f docs/sitemap.xml ]; then
    grep -v '<lastmod>' docs/sitemap.xml > docs/sitemap.xml.tmp && mv docs/sitemap.xml.tmp docs/sitemap.xml
  fi
  for d in decks-notes seminar-teachers; do
    mkdir -p "docs/$d"
    [ -d "$keep/$d" ] && cp -R "$keep/$d/." "docs/$d/"
  done
  if [ -d "$keep/solutions" ]; then
    mkdir -p docs/solutions
    cp -R "$keep/solutions/." docs/solutions/
  fi
  rm -rf "$keep"
  if [ -d instructor/_rendered ]; then
    find instructor/_rendered -name "*-instructor.html" -exec cp {} docs/decks-notes/ \;
    find instructor/_rendered -name "*_complete.html" -exec cp {} docs/seminar-teachers/ \;
    find instructor/_rendered -name "teacher_note*.html" -exec cp {} docs/seminar-teachers/ \;
  fi
  if [ -d instructor/_rendered/solutions ]; then
    for f in instructor/_rendered/solutions/*_solutions.html; do
      [ -e "$f" ] || continue
      mkdir -p docs/solutions
      cp "$f" docs/solutions/
    done
  fi
  # A notebook with solutions stays published only while its week's block links to it.
  for c in instructor/weeks/*/notebooks/*_complete.qmd; do
    [ -e "$c" ] || continue
    w=$(basename "$(dirname "$(dirname "$c")")")
    base=$(basename "${c%_complete.qmd}")
    released "$w" "$base" || rm -f "docs/solutions/${base}_solutions.html"
  done
  if [ -d docs/solutions ]; then rmdir docs/solutions 2>/dev/null || true; fi
}

build() {
  student
  instructor
  solutions
  site
  check
}

check() {
  local fail=0 n s c w base
  n=$(find docs -name '*_complete*' -not -path 'docs/seminar-teachers/*' | wc -l | tr -d ' ')
  [ "$n" -eq 0 ] || { echo "FAIL: _complete files under docs/"; fail=1; }
  [ ! -e docs/instructor ] || { echo "FAIL: docs/instructor/ exists"; fail=1; }
  if grep -rlq --exclude-dir=seminar-teachers --exclude-dir=solutions 'Reveal answer\|Reveal solution' docs; then echo "FAIL: answer boxes in docs/ outside seminar-teachers/ and solutions/"; fail=1; fi
  # A notebook with solutions is published exactly when its week's block on the course page links to it.
  for c in instructor/weeks/*/notebooks/*_complete.qmd; do
    [ -e "$c" ] || continue
    w=$(basename "$(dirname "$(dirname "$c")")")
    base=$(basename "${c%_complete.qmd}")
    if released "$w" "$base" && [ ! -e "docs/solutions/${base}_solutions.html" ]; then echo "FAIL: weeks/$w/_index.qmd links to a notebook with solutions that is not in docs/ (run WEEK=$w _build_env/build.sh solutions, then site)"; fail=1; fi
    if ! released "$w" "$base" && [ -e "docs/solutions/${base}_solutions.html" ]; then echo "FAIL: docs/solutions/${base}_solutions.html is published but weeks/$w/_index.qmd does not link to it (not released)"; fail=1; fi
  done
  if [ -d docs/solutions ]; then
    n=$(find docs/solutions -type f -not -name 'notebook*_solutions.html' | wc -l | tr -d ' ')
    [ "$n" -eq 0 ] || { echo "FAIL: something other than notebookN_solutions.html under docs/solutions/"; fail=1; }
    if grep -lq 'class="notes"' docs/solutions/*.html 2>/dev/null; then echo "FAIL: speaker notes under docs/solutions/"; fail=1; fi
  fi
  if grep -rlq --exclude-dir=decks-notes 'class="notes"' docs --include='*.html'; then echo "FAIL: speaker notes in docs/"; fail=1; fi
  [ "$(cat docs/CNAME 2>/dev/null)" = "ml4ds.com" ] || { echo "FAIL: docs/CNAME"; fail=1; }
  # Under instructor/ only the complete notebooks and the teacher notes are tracked.
  n=$(git ls-files | grep '^instructor/' | grep -vEc '^instructor/weeks/[^/]*/(notebooks/[^/]*_complete|teacher_note[^/]*)\.qmd$' || true)
  [ "$n" -eq 0 ] || { echo "FAIL: instructor files other than complete notebooks and teacher notes tracked by git"; fail=1; }
  # Assessments never go in the repository, under any name.
  if git ls-files | grep -iEq '(^|/)private/|(^|[/_-])exams?([._/-]|$)|problem[_-]?sets?([._/-]|$)|(^|[/_-])psets?([._/-]|$)|held_problems'; then echo "FAIL: an exam, problem-set or private file is tracked by git"; fail=1; fi
  for s in weeks/*/notebooks/notebook*.qmd; do
    [ -e "$s" ] || continue
    [ -e "docs/$s" ] || { echo "FAIL: $s not in docs/ (check the resources: pattern in _quarto.yml)"; fail=1; }
  done
  if grep -lq '\.answer' weeks/*/notebooks/*.qmd 2>/dev/null; then echo "FAIL: .answer div in a student notebook"; fail=1; fi
  # Every teacher page must be self-contained (no sibling _files folder is published).
  if grep -lq '_files/libs/' docs/seminar-teachers/*.html docs/decks-notes/*.html docs/solutions/*.html 2>/dev/null; then echo "FAIL: a page under docs/seminar-teachers/, docs/decks-notes/ or docs/solutions/ is not self-contained"; fail=1; fi
  # Every page uses MathJax 4 (html-math-method in _quarto.yml). A deck that ends up without a math
  # method gets MathJax 2.7.9 from reveal's plugin; one that names another URL gets that.
  if grep -rlq --include='*.html' -e "mathjax: 'https://cdn.jsdelivr.net/npm/mathjax@[0-3]" docs; then echo "FAIL: a deck loads a MathJax older than 4 (check html-math-method in its YAML and in _quarto.yml)"; fail=1; fi
  # Nothing under seminar-teachers/ or decks-notes/ is linked from a public page. What students get,
  # the week after the seminar, is the notebook with solutions under solutions/.
  n=$(grep -rlE --include='*.html' --exclude-dir=seminar-teachers --exclude-dir=decks-notes -e 'href="[^"]*seminar-teachers/' -e 'href="[^"]*decks-notes/' docs | tr '\n' ' ' || true)
  [ -z "$n" ] || echo "WARN: public page links to a teacher path: $n"
  # The site is built with one Quarto version; another one rewrites every page.
  if [ -f _build_env/QUARTO_VERSION ] && [ "$(quarto --version 2>/dev/null)" != "$(cat _build_env/QUARTO_VERSION)" ]; then
    echo "WARN: quarto $(quarto --version 2>/dev/null) here, site built with $(cat _build_env/QUARTO_VERSION): every page will change"
  fi
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
  git push origin HEAD
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
  import|student|instructor|solutions|site|build|check|push|deploy) "$cmd" "$@" ;;
  *) sed -n '2,24p' "$0"; exit 1 ;;
esac
