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
#   _build_env/build.sh solutions                     generate each week's notebook with solutions from its complete notebook and render it
#                                                     -> _solutions/ (tracked, not published); a notebook whose source has not changed is
#                                                     skipped (FORCE=1 renders it again)
#   _build_env/build.sh site                          public render -> docs/ (unchanged pages come from _freeze/), teacher pages kept
#                                                     (decks with notes -> docs/decks-notes/; complete notebooks and teacher notes -> docs/seminar-teachers/;
#                                                     for a released week, its stored notebook with solutions -> docs/solutions/)
#   _build_env/build.sh check                         gates; non-zero exit on any failure
#   _build_env/build.sh push "<commit message>"       check, then git add/commit/push the current branch
#   _build_env/build.sh deploy <delivery-folder> "<commit message>"    import, student, instructor, solutions, site, check, push (Dropbox fallback)
#
# WEEK=02-regression restricts the instructor and solutions renders to that week's folder. The instructor renders
# always execute their code, so rendering a week you did not change rewrites its teacher pages for nothing.
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
# document from the teacher's complete notebook (convenor, 8 October 2026), generated from it.
# It is rendered when its week is built and stored, tracked, in _solutions/ with the hash of its
# generated source (convenor, 9 October 2026). Nothing there is published: site copies a stored
# notebook to docs/solutions/ only once the week's block links to it. So a release adds a link
# and copies a file; it renders nothing and needs no R.
SOL=_solutions

sol_state() {   # current | stale | missing, for the complete notebook $1
  local base
  base=$(basename "${1%_complete.qmd}")
  [ -e "$SOL/${base}_solutions.html" ] || { echo missing; return 0; }
  if [ "$(cat "$SOL/${base}_solutions.sha256" 2>/dev/null)" = "$(python3 _build_env/make_incomplete.py --solutions-hash "$1")" ]; then
    echo current
  else
    echo stale
  fi
}

solutions() {
  # A notebook whose source has not changed since its stored page was rendered is skipped, so a
  # released page does not change under the students when another week is built. The hash covers
  # the source only: after a change to data, packages or the theme, use FORCE=1.
  local c base s out
  mkdir -p "$SOL"
  for c in instructor/weeks/${WEEK:-*}/notebooks/*_complete.qmd; do
    [ -e "$c" ] || continue
    base=$(basename "${c%_complete.qmd}")
    if [ -z "${FORCE:-}" ] && [ "$(sol_state "$c")" = current ]; then
      echo "${base}_solutions: stored page is current, not rendered again (FORCE=1 to render)"
      continue
    fi
    s="${c%_complete.qmd}_solutions.qmd"
    python3 _build_env/make_incomplete.py --solutions "$c" "$s"
    quarto render "$s" --embed-resources
    # The output is under docs/ (project output-dir) or beside the source.
    out="${s%.qmd}.html"
    if [ -e "docs/$out" ]; then
      mv "docs/$out" "$SOL/"
    elif [ -e "$out" ]; then
      mv "$out" "$SOL/"
    else
      echo "RENDER FAILED: no output found for $s"; exit 1
    fi
    python3 _build_env/make_incomplete.py --solutions-hash "$c" > "$SOL/${base}_solutions.sha256"
    # The generated source and what its render leaves beside it are not kept.
    rm -rf "$s" "${s%.qmd}_cache" "${s%.qmd}_files"
  done
  rm -rf docs/instructor
  echo "notebooks with solutions in $SOL/"
}

site() {
  local keep d c w base f
  # The teacher pages of weeks not re-rendered this time exist only in docs/: keep them across the clean render.
  keep=$(mktemp -d)
  for d in decks-notes seminar-teachers; do
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
  rm -rf "$keep"
  if [ -d instructor/_rendered ]; then
    find instructor/_rendered -name "*-instructor.html" -exec cp {} docs/decks-notes/ \;
    find instructor/_rendered -name "*_complete.html" -exec cp {} docs/seminar-teachers/ \;
    find instructor/_rendered -name "teacher_note*.html" -exec cp {} docs/seminar-teachers/ \;
  fi
  # A notebook with solutions is published exactly while its week's block links to it: the stored
  # page is copied, nothing is rendered. docs/solutions/ was removed with docs/ above.
  for c in instructor/weeks/*/notebooks/*_complete.qmd; do
    [ -e "$c" ] || continue
    w=$(basename "$(dirname "$(dirname "$c")")")
    base=$(basename "${c%_complete.qmd}")
    f="$SOL/${base}_solutions.html"
    if released "$w" "$base" && [ -e "$f" ]; then
      mkdir -p docs/solutions
      cp "$f" docs/solutions/
    fi
  done
}

build() {
  student
  instructor
  solutions
  site
  check
}

check() {
  local fail=0 n s c w base st
  n=$(find docs -name '*_complete*' -not -path 'docs/seminar-teachers/*' | wc -l | tr -d ' ')
  [ "$n" -eq 0 ] || { echo "FAIL: _complete files under docs/"; fail=1; }
  [ ! -e docs/instructor ] || { echo "FAIL: docs/instructor/ exists"; fail=1; }
  if grep -rlq --exclude-dir=seminar-teachers --exclude-dir=solutions 'Reveal answer\|Reveal solution' docs; then echo "FAIL: answer boxes in docs/ outside seminar-teachers/ and solutions/"; fail=1; fi
  # A notebook with solutions is published exactly when its week's block on the course page links to it,
  # and what is published is the stored page, made from the complete notebook as it is now. For a week
  # not yet released a missing or old stored page is a WARN, for the week's own agent: it must not stop
  # another week's push. For a released week it is a FAIL: students would get no page or an old one.
  for c in instructor/weeks/*/notebooks/*_complete.qmd; do
    [ -e "$c" ] || continue
    w=$(basename "$(dirname "$(dirname "$c")")")
    base=$(basename "${c%_complete.qmd}")
    st=$(sol_state "$c")
    if released "$w" "$base"; then
      case "$st" in
        missing) echo "FAIL: weeks/$w/_index.qmd links to a notebook with solutions, and there is no stored page $SOL/${base}_solutions.html (run WEEK=$w _build_env/build.sh solutions, then site; needs R)"; fail=1 ;;
        stale) echo "FAIL: the notebook with solutions ${base}_solutions is older than $c (run WEEK=$w _build_env/build.sh solutions, then site; needs R)"; fail=1 ;;
      esac
      if [ -e "$SOL/${base}_solutions.html" ] && ! cmp -s "$SOL/${base}_solutions.html" "docs/solutions/${base}_solutions.html"; then
        echo "FAIL: docs/solutions/${base}_solutions.html is missing or is not the stored page in $SOL/ (run _build_env/build.sh site)"; fail=1
      fi
    else
      if [ -e "docs/solutions/${base}_solutions.html" ]; then echo "FAIL: docs/solutions/${base}_solutions.html is published but weeks/$w/_index.qmd does not link to it (not released)"; fail=1; fi
      case "$st" in
        missing) echo "WARN: no stored notebook with solutions for $w (run WEEK=$w _build_env/build.sh build); without it the week's release has to render it" ;;
        stale) echo "WARN: the stored ${base}_solutions is older than $c (run WEEK=$w _build_env/build.sh build)" ;;
      esac
    fi
  done
  # _solutions/ holds one page and its source hash per notebook, and none of it is under docs/ before release.
  if [ -d "$SOL" ]; then
    n=$(find "$SOL" -type f -not -name 'notebook*_solutions.html' -not -name 'notebook*_solutions.sha256' | tr '\n' ' ')
    [ -z "$n" ] || { echo "FAIL: something other than notebookN_solutions.html and its .sha256 under $SOL/: $n"; fail=1; }
    if grep -lq 'class="notes"' "$SOL"/*.html 2>/dev/null; then echo "FAIL: speaker notes under $SOL/"; fail=1; fi
  fi
  [ ! -e "docs/$SOL" ] || { echo "FAIL: docs/$SOL exists: the stored notebooks with solutions were published"; fail=1; }
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
  if grep -lq '_files/libs/' docs/seminar-teachers/*.html docs/decks-notes/*.html docs/solutions/*.html "$SOL"/*.html 2>/dev/null; then echo "FAIL: a page under docs/seminar-teachers/, docs/decks-notes/, docs/solutions/ or $SOL/ is not self-contained"; fail=1; fi
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
  solutions
  site
  push "${2:?commit message required}"
}

cmd="${1:-}"; shift || true
case "$cmd" in
  import|student|instructor|solutions|site|build|check|push|deploy) "$cmd" "$@" ;;
  *) sed -n '2,24p' "$0"; exit 1 ;;
esac
