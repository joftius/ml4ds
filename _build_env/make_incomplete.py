#!/usr/bin/env python3
"""Derive the student notebook from the teacher (_complete) one.

Usage:  make_incomplete.py <complete.qmd> <student.qmd>
        make_incomplete.py --check <complete.qmd>      (marker balance only)

Revised 26 September 2026 for the 2026-27 seminar format: the teacher file
carries every answer in a collapsible callout that the seminar teacher opens on
screen, and the student file is the teacher file with those callouts removed.

Markers in the complete file:
  ::: {.callout-tip .answer collapse="true" title="Reveal answer"}
  ...
  :::
      Any fenced div whose opening line carries the class `.answer` is removed
      entirely, up to the next line consisting of `:::` alone. Answer divs must
      not nest other fenced divs. Prose answers ("Reveal answer") and solution
      code chunks ("Reveal solution") use the same marker.
  <details><summary>Hint ...</summary> ... </details>
      Kept as they are (collapsed in both renders).

Everything else is copied verbatim. Skeleton chunks mark the place for the
student's code with a commented line `# ...` (from 7 October 2026; a bare `...`
is still recognized), so there is no line to delete. They already carry
`#| eval: false` in the complete file (so that the teacher render does not
evaluate them either); the generator adds it where it is missing. The YAML title loses its " (complete)" suffix, and the teacher-only
HTML comment at the top is dropped. The script exits non-zero if an answer div
is opened and never closed.
"""
import sys, re

NOTICE = (
    "::: {.callout-note}\n"
    "This is the student version of the notebook. The code you write goes where "
    "a line says `# ...` or has a `____`. "
    "A code chunk with a blank starts with `#| eval: false`, so the file "
    "renders as it stands; delete that line once you have filled the blank. "
    "Working through the chunks one at a time in RStudio (Ctrl/Cmd+Enter) is "
    "unaffected. Answers are revealed in the seminar.\n"
    ":::\n"
)

OPEN = re.compile(r"^:::+\s*\{[^}]*\.answer[^}]*\}\s*$")
BLANK = re.compile(r"^[ \t]*(#[ \t]*)?\.\.\.[ \t]*$", flags=re.M)
CLOSE = re.compile(r"^:::+\s*$")

def check_markers(txt, name):
    problems = []
    lines = txt.split("\n")
    open_at = None
    for i, line in enumerate(lines, 1):
        if OPEN.match(line):
            if open_at is not None:
                problems.append(f"{name}: answer div opened at line {open_at} not closed before line {i}")
            open_at = i
        elif CLOSE.match(line) and open_at is not None:
            open_at = None
    if open_at is not None:
        problems.append(f"{name}: answer div opened at line {open_at} never closed")
    if "ANSWER" in txt:
        problems.append(f"{name}: legacy 'ANSWER' marker found; this generator uses .answer divs")
    return problems

def derive(txt):
    out, skipping = [], False
    for line in txt.split("\n"):
        if not skipping and OPEN.match(line):
            skipping = True
            continue
        if skipping:
            if CLOSE.match(line):
                skipping = False
            continue
        out.append(line)
    txt = "\n".join(out)
    # collapse runs of blank lines left by removed divs
    txt = re.sub(r"\n{3,}", "\n\n", txt)
    # title suffix
    txt = txt.replace(" (complete)", "", 1).replace("(complete)", "", 1)
    # teacher-only comment immediately after the YAML header
    txt = re.sub(r"(---\n.*?\n---\n)\s*<!-- Teacher version\..*?-->\n", r"\1", txt, count=1, flags=re.S)
    # chunks that contain a blank do not evaluate in the student render
    def chunk_repl(m):
        fence, body, close = m.group(1), m.group(2), m.group(3)
        has_blank = BLANK.search(body) is not None
        has_eval = re.search(r"^#\|\s*eval\s*:", body, flags=re.M) is not None
        if has_blank and not has_eval:
            body = "#| eval: false\n" + body
        return fence + body + close
    txt = re.sub(r"(^```\{r[^\n]*\}\n)(.*?)(^```[ \t]*$\n?)", chunk_repl, txt, flags=re.S | re.M)
    # notice after the YAML header
    m = re.match(r"---\n.*?\n---\n", txt, flags=re.S)
    if m:
        txt = txt[:m.end()] + "\n" + NOTICE + txt[m.end():]
    return txt

if __name__ == "__main__":
    args = sys.argv[1:]
    if args and args[0] == "--check":
        src = args[1]
        problems = check_markers(open(src).read(), src)
        for p in problems:
            print(p, file=sys.stderr)
        sys.exit(1 if problems else 0)
    src, dst = args[0], args[1]
    txt = open(src).read()
    problems = check_markers(txt, src)
    if problems:
        for p in problems:
            print(p, file=sys.stderr)
        sys.exit(1)
    out = derive(txt)
    open(dst, "w").write(out)
    n_ans = len(BLANK.findall(out))
    n_off = len(re.findall(r"^#\| eval: false$", out, flags=re.M))
    n_left = len(re.findall(r"\.answer|Reveal (answer|solution)", out))
    print(f"wrote {dst}: {n_ans} blanks; {n_off} chunks with eval: false; {n_left} answer markers left")
