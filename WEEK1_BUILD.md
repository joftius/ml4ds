# Week 1 build — 26 September 2026

Files for the 2026-27 week 1, built to the spine agreed on 26 September 2026 (project doc `claude/ST310_spine_2026-27.md`). Paths mirror the Quarto tree of the 25 September build in `ST310/elthree/` (undated top level); these files are meant to be dropped over that tree. Sources: the legacy decks and notebook in `ST310/current/weeks/01-introduction-foundations/`, the 25 September revised deck and notebook, cc's `board_theorem_A.qmd`, and the two review syntheses' week-1 items.

## Files

| File | Status | Base |
|---|---|---|
| `weeks/01-introduction-foundations/slides/01-1-introduction.qmd` | new deck, one 85-minute lecture | legacy `01-1-introduction.Rmd` + `01-2-foundations.Rmd`; 25 Sept `01-1-introduction.qmd` |
| `theme/st310.scss` | recoloured | 25 Sept `theme/st310.scss` |
| `instructor/weeks/01-introduction-foundations/notebooks/notebook1_complete.qmd` | new teacher notebook: problem set + coding, answers in collapsible boxes | legacy `notebook1_complete.Rmd`; 25 Sept `notebook1_complete.qmd` |
| `weeks/01-introduction-foundations/notebooks/notebook1.qmd` | **generated** student notebook; never edit by hand | from the file above via `_build_env/make_incomplete.py` |
| `_build_env/make_incomplete.py` | revised generator (answer callouts instead of comment markers) | 25 Sept version |
| `_build_env/strip_notes.lua` | unchanged copy, so the deck renders from this folder alone | 25 Sept version |

Not included, used as they stand from the 25 September build: `_quarto.yml`, `index.qmd`, `about.qmd`, `instructor/index.qmd`, `board_theorem_A.qmd`, `teacher_note_w01.qmd`, the templates. Two of those need one-line edits before the site is rendered: `_quarto.yml` `resources:` lists `*_incomplete.qmd`; the student file is now `notebook1.qmd`, so the pattern should read `weeks/01-introduction-foundations/notebooks/notebook1.qmd`; and `index.qmd`'s week-1 notebook link should point at `notebook1.html`. `files/lasso.gif` and `files/sticker.png` come from `ST310/current/files/`.

## Deck: what came from where

Order and timing in the speaker notes of the title slide (total 85; cut order; pace waypoints). The notes are stripped from the public render by `strip_notes.lua`.

| Slides | Source | Change |
|---|---|---|
| Title; About the course; Format; How the course works | legacy `01-1` | Format: "Seminars: problems on paper first, then computing"; PPA named alongside MLstory's URL; R4DS/ESL/CASI links updated to current hosts. Assessments slide replaced by the 25 Sept "How the course works" (course-guide pointer; formative problem sets; seminar problems; no exam mention), with a line on what the seminar problems are for. |
| Quick preview (tabset); xkcd | legacy `01-1` | xaringan panelset → Quarto `panel-tabset`; plot colours to viridis; xkcd kept with credit line and licence; lasso gif kept. |
| Teaching philosophy; Recurring themes; self-intro | legacy `01-1` | "Come post on the forum" replaced by "problems on paper in every seminar; solve your own problems" (no forum this year). Self-intro as text; bridge photo dropped (theme images removed from the tree). |
| What is ML; applications; ML proper | legacy `01-2` | Unchanged text. The "What is AI" slide with the hotlinked word-embedding image dropped. |
| **Machine learning, the field** | new | Two lineages (statistics / computer science), Breiman's two cultures, ICML 1980, NeurIPS 1987, COLT 1988, *Machine Learning* 1986, JMLR 2001; conference papers as the currency. Two minutes. |
| Notation; categories; sub-categories; focus on regression | legacy `01-2` | "Unsupervised learning (a bit of this)" → "Not this course: unsupervised learning, ranking, …" (convenor, 26 Sept). Imgflip meme dropped. |
| How to predict; probability; very useful assumptions | legacy `01-2` | Unchanged. |
| This is what ML is, this term; **the CTF in three dates**; October 2006; And then | cc / 25 Sept; new | The CTF is named on the slide (convenor: name it, with a small history): 1986 DARPA/NIST, 2006 Netflix, 2010 Kaggle + ILSVRC; Donoho 2017. ImageNet curve slide dropped (was the standing cut). Netflix figures as corrected on 25 Sept (C028, C035). |
| Prediction, loss, held-out set; One rule; Your first task | cc / 25 Sept | Unchanged text; the task slide moved after the rule so the rule precedes the first prediction. |
| Where would you look; 1951 | cc / 25 Sept | Fix–Hodges kept at 2 minutes (second on the cut order); Cover–Hart qualified (C032). |
| k-NN; which k; the score for every k; the leaderboard; the smooth cousin | cc / 25 Sept | Colours to viridis/magma; leaderboard caption as decided on 25 Sept (D10.2). Smooth cousin at 1 minute, with its question. |
| Theorem A board slide + 4 backups; where the bias comes from | cc / 25 Sept | Unchanged, with C001's non-monotone bias wording, the `{.ask}` in place of the recall box (D6), and the loess stand-in note (B-01-16). Legacy's bias–variance headline slides are absorbed here (the notes say so). |
| The curse; Far away; Distances concentrate | cc / 25 Sept | **"1957" Bellman slide dropped** (convenor); one sentence of attribution moved into the notes of the curse slide. B-01-02 order (ask before the rule), C184 cube scope, B-01-03 mechanism sentence, C034 union-bound clause all carried over. |
| A request | legacy Moodle text + cc | Moodle wording ("As a courtesy to me … We are here to train our own minds, not to replace them") plus cc's "I'm an interested party" line. |
| Two things to think about; Until the seminar; Reading | cc / 25 Sept | Week numbers removed from the notes ("the validation week"); reading list without page numbers (not checked against the current edition). |

Legacy slides dropped: candy ranking example; gapminder "simpler / too complex?" pair and the "evaluation: MSE — a victory for ML?" slide (replaced by the k-NN score curve and leaderboard); the "bias–variance trade-off" and "with model complexity" slides (replaced by Theorem A); the graduation-photo slide; the "What is AI" slide.

Timing line: 1 + 5 + 3 + 3 + 11 + 6 + 8 + 5 + 3 + 12 + 15 + 2 + 5 + 2 + 2 + 2 = 85. History on the slides: the CTF dates 3, Netflix 5, Fix–Hodges 2 = 10 minutes, a recorded overrule of the five-minute budget for week 1 (the convenor asked for both).

Divider slides use `## Title {.inverse .center}` with body text below; a level-1 heading inside an untitled inverse slide splits into a separate title slide in Quarto and loses the dark background (found in the render, fixed).

## Notebook

Seminar plan, 80 minutes inside the 90 booked: opener 5; problems 25 (four problems, answers revealed progressively); coding 50 (competition 12, k-NN by hand 25, the score's SE 8, predicting on 1997 5); exit 5.

- **Problem set (new).** Four problems that rebuild Theorem A's pieces: (1) $\mathbb E Z^2 = \sigma^2 + \mu^2$ and the bias–variance step; (2) variance of a mean of independent terms, and of identical ones; (3) the cross term vanishes under independence, and does not at a training point; (4) k-NN by hand on five points, training error zero, $k = n$ is the baseline. Each answer ends with a common error and a minimal hint.
- **Coding.** Legacy structure (gapminder scatterplot → models → MSE → predicting on 1997) with cc's competition framing and k-NN by hand in place of `loess`: split 100/42 in 2007; baseline and `lm` entrants; `knn_predict` with a `for` loop (checked first against problem 4's numbers), one-country check, loop over the test set, `knn_mse` over seven values of $k$, training and test curves; the score's standard error; predictions on 1997 with `newdata` and the "has it predicted anything new?" question (the lecture's closing question 2). Checkpoints after each k-NN stage (B-01-06); Question 2 before the table (B-01-07); Question 3 names the reuse (B-01-08); the hint collapsed (B-01-05).
- **Dropped from the 25 Sept notebook:** the repeated-competition simulation and its Question 4 (time), the alternative datasets (candy is out; concrete not needed). **Dropped from legacy:** the `loess` fits, the simulation of a nonlinear function and the sampling distribution of the slope (time; the slope's sampling distribution belongs with regression). `qplot` and `size =` on lines are gone with them.
- **Answers.** Every answer is a `::: {.callout-tip .answer collapse="true" title="Reveal …"}` box: collapsed in the teacher's render, opened by clicking. The student file is the same file with those boxes removed. Solutions are not released. Teacher-only guidance (when to reveal) sits in the HTML comment at the top of the complete file, which the generator drops.
- **Generator.** `make_incomplete.py` now strips `.answer` divs instead of `ANSWER` comment markers; skeleton chunks carry `#| eval: false` in both files so neither render evaluates a blank; the checkpoint and plot chunks are guarded with `#| eval: !expr exists(...)` as on 25 Sept. Output: 11 blanks, 9 non-evaluating chunks, 0 answer markers left.

## Checks

Run:

- Generator marker check; `grep` of the student file for "Reveal", ".answer", "Common error", "two thirds": 0 hits. `grep -i exam` on deck and both notebooks: only the word "example".
- WCAG contrast ratios of every text colour in the theme (in the file header).
- **Render (mechanics only).** Quarto 1.x and R 4.x in a Linux container with tidyverse, knitr, rmarkdown, broom and viridisLite; the `gapminder` package could not be installed there (CRAN unreachable), so the render used a *simulated stand-in table with the same columns* (`gapminder_stub.R`, not shipped). This checks that the code runs, the tabsets, callouts, notes filter and theme work, and nothing errors; it does **not** check the figures' numbers, the leaderboard ordering, or any claim about the real data (e.g. "usually 115–190"). Results: deck public render 0 speaker notes, 0 error blocks, 48 slides (45 counted, 4 backups uncounted); instructor render (`ST310_KEEP_NOTES=1`) 25 notes; teacher notebook 0 error blocks, 20 collapsed answer boxes; student notebook 0 error blocks, 0 answer boxes, no solution code. Screenshots of seven slides checked for the theme (dark dividers, heading and emphasis colours, `.ask` boxes); MathJax and the xkcd/lasso images did not load offline, which is expected.

Not run: a render with the real `gapminder` data (do this first on your machine: `quarto render` the deck and both notebooks, and look at the leaderboard and score-curve slides); a timing pilot; page numbers of the readings; the Netflix and CTF-history figures taken from the 25 Sept notes and from memory (Liberman/DARPA 1986, Donoho 2017, Kaggle 2010, conference dates), not re-fetched; the deployed `_weeks/` not compared against `current/`.

## Notes

- The student notebook is `notebook1.qmd` (no `_incomplete` suffix), the legacy name; the teacher file keeps `_complete`. `_quarto.yml` and `index.qmd` in the 25 Sept tree still expect `_incomplete` (one-line edits, above).
- The theme's usable text colours are `#440154`, `#31688e`, `#8c2981`, `#b73779`; viridis green and yellow fail contrast on white (2.1:1 and 1.3:1) and are used only as borders, backgrounds, and text on the dark slides. Plot code uses named colour variables set in the deck's setup chunk.
- Quarto callouts with an extra class (`.answer`) keep the class on the rendered div; the generator relies on that class, not on the title text. Collapsed callouts are the reveal mechanism; no JavaScript of ours.
- In Quarto revealjs a `# Level-1 heading` always starts a new slide, even inside a `## {.inverse}` slide; write dividers as `## Title {.inverse .center}`.
