---
title: "Palmer penguins"
description: "344 penguins of three species measured at Palmer Station, Antarctica, 2007–2009: bill, flipper, body mass, sex, island. Small and clean; the classification data for the week-3 seminar."
---

| | |
|---|---|
| **Provenance and license** | Gorman, Williams and Fraser (2014), Palmer Station Long Term Ecological Research program; packaged by Horst, Hill and Gorman as `palmerpenguins`. The R package and its data are CC0. |
| **R access** | `palmerpenguins::penguins`. Use the qualified name: `modeldata` also exports a `penguins` (7 columns, no `year`) and masks it when attached later. |
| **Unit of observation** | A penguin (344 rows), 8 columns: `species`, `island`, `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm`, `body_mass_g`, `sex`, `year`. |
| **Target and loss** | Week 3: `species`, Adelie against Chinstrap (219 birds after dropping incomplete measurements), 0--1 loss or a cost-weighted loss with the costs stated. |
| **Available at prediction time** | The measurements and `island`, `sex`, `year`. In this dataset `island` completely separates Chinstrap from Gentoo (Chinstraps are on Dream, Gentoos on Biscoe; Adelies occur on all three islands), so a model with `island` in it is solving a different, easier task; say so if a student uses it. |
| **Permitted predictors** | Week 3: `bill_length_mm` and `bill_depth_mm` (the default), `flipper_length_mm` alone (the weak model for the ROC curve). |
| **Missingness** | Two birds lack all four measurements; eleven lack `sex`. `drop_na()` on the columns used. |
| **Split unit and seed** | Birds. Week 3 fits on all 219 birds with no split: the point is the mechanism, and every number in the seminar is computed on the training rows (apparent performance; the validation week says what that flatters). |
| **Baseline** | Predict the majority class, Adelie: accuracy 0.69 on the two-species task. |
| **Complication it carries** | None social. Near-separability: the bill model has six errors in 219 birds and `glm` warns about fitted probabilities of 0 or 1, a live example of the lecture's "too easy" slide. |
| **Limitations** | Three islands, three seasons, one research program: a clean dataset with no deployment story, which is why it is used when the mechanism is the lesson. |
| **Fictional?** | No. |

## Loader

```r
library(palmerpenguins)
pg <- palmerpenguins::penguins |>
  dplyr::filter(species != "Gentoo") |>
  tidyr::drop_na(bill_length_mm, bill_depth_mm, flipper_length_mm) |>
  dplyr::mutate(chinstrap = as.numeric(species == "Chinstrap"))
```
