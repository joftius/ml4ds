---
title: "Movies"
description: "58,788 films from the Internet Movie Database with year, length, average user rating and vote counts; 53,388 after the course's selection. The additive-model data: rating on length and year, fitted in week 5 and backfitted in week 8."
---

| | |
|---|---|
| **Provenance and licence** | The IMDb data extracted by Hadley Wickham for the `ggplot2` package's original `movies` dataset and moved to the `ggplot2movies` package. Its documentation says films were included if they had a known length and at least one user rating; the shipped data run to 2005 and every film has at least five votes (the documentation's row count, 28,819, is stale against the 58,788 shipped). GPL-3 for the package (`packageDescription("ggplot2movies")$License`). IMDb's own terms restrict commercial use of its data; this is teaching. |
| **R access** | `ggplot2movies::movies` (package version 0.0.1). |
| **Unit of observation** | A film (58,788 rows), 24 columns: `title`, `year` (1893–2005), `length` (minutes), `budget` (91% missing), `rating` (average user rating, 1–10), `votes`, `r1` to `r10` (the share of users giving each rating, coarsened), `mpaa` (blank for 92% of films), and seven genre indicators (`Action`, `Animation`, `Comedy`, `Drama`, `Documentary`, `Romance`, `Short`). |
| **Target and loss** | `rating` with squared error. |
| **Available at prediction time** | `year`, `length`, the genre indicators. `votes` and the `r1`–`r10` columns come from the same users' ratings and are not honest predictors of `rating` (the `r` columns nearly determine it). `budget` is mostly missing. |
| **Permitted predictors** | Weeks 5 and 8 use `length` and `year` only, as smooth terms. Genre indicators may be added as linear terms in `mgcv` (`+ Comedy + Drama`). |
| **Missingness** | `budget` 91% missing and unused; nothing else. |
| **Selection** | The course filters to `length <= 200`, `length > 10`, `year > 1918`, `votes >= 5` (the last removes nothing): 53,388 films. The 4,805 films of ten minutes or less are shorts, the 250 above 200 minutes are serials and epics, and the 630 films from before 1919 are sparse; each group would dominate the ends of a length or year curve. |
| **Split unit** | Films. No seed in the seminar notebook, so a random 70/30 split and a subsample of 5,000 for the by-hand loop differ across students. The split in time (train before 1990, test from 1990 on) is deterministic: 31,412 and 21,976 films. It is a retrospective check using one snapshot of ratings, not a forecast made in 1990. |
| **Baseline** | Predict the mean rating (5.88): mean squared error 2.43 (the variance of `rating`). The additive model on length and year reaches about 2.15 on a random split, and 3.16 on the split in time, worse than the training mean (2.66). |
| **Methods that use it** | Week 5: the additive model as least squares on spline basis functions, `lm(rating ~ ns(length, 8) + ns(year, 8))`, and its component plots. Week 8: the separate smooth against the backfitted component; `mgcv`; backfitting by hand on a subsample; the two splits. The legacy GAM deck and notebook used the same data. |
| **Complication it carries** | Ratings come from people who chose to watch a film and then to rate it. Films of 60 to 80 minutes are mostly old (median year 1956), and older films here are rated higher; one plausible explanation is that the old films still watched are the ones that survived, but the association does not identify that, and cohort and genre are other explanations the data cannot separate. The split in time shows a second complication: films from 1990 on have years the training data never contained, so the year component is evaluated outside its data. |
| **Limitations** | Ratings up to 2005 from a site whose users were not a sample of anyone; `length` as reported to IMDb; no director, cast, language or country. Fine for the mechanism of additive fitting and for the two splits, not for a claim about films. |
| **Fictional?** | No. |

## Loader

```r
library(ggplot2movies)
mv <- movies |>
  dplyr::filter(length <= 200, length > 10, year > 1918, votes >= 5)
```
