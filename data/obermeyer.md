---
title: "Health system patients (synthetic)"
description: "Synthetic patient-years released with Obermeyer et al. (2019), mimicking the patients of one US health system and the commercial algorithm it used to predict their costs."
---

| | |
|---|---|
| **Source** | Obermeyer, Z., Powers, B., Vogeli, C. and Mullainathan, S. (2019), "Dissecting racial bias in an algorithm used to manage the health of populations", *Science* 366(6464), 447--453, [doi:10.1126/science.aax2342](https://doi.org/10.1126/science.aax2342). The authors released a synthetic version of their data, with a data dictionary and their code: [gitlab.com/labsysmed/dissecting-bias](https://gitlab.com/labsysmed/dissecting-bias). The course reads the file from there and does not host it. |
| **Rows** | 48,784 patient-years, each one row: 5,582 of Black and 43,202 of White patients. The rows were generated with the R package `synthpop` from the study's data, so no row is a real patient, and, unlike the original data, the rows are not grouped by patient. |
| **Columns** | 160. Measured in the year before (names ending `_tm1`): age band, sex, 34 chronic conditions and their count `gagne_sum_tm1`, 13 kinds of cost, and 94 indicators of test results and medications. Measured in the year itself (names ending `_t`): `cost_t` (total cost, rounded to \$100), `cost_avoidable_t` (emergency and inpatient), `gagne_sum_t` (number of active chronic conditions), five test results, `program_enrolled_t`, and `risk_score_t`, the commercial algorithm's score. Also `race`. |
| **Targets** | Whether `cost_t` is in the top quarter; `cost_t`; `gagne_sum_t`. |
| **Notes** | Claims about these rows are claims about the synthetic data, which mimic the study's data in their moments and covariances. The commercial algorithm did not use race, and the course's models do not either. |

## Loader

```r
library(tidyverse)
hs <- read_csv("https://gitlab.com/labsysmed/dissecting-bias/-/raw/master/data/data_new.csv")
outcomes_t <- c("risk_score_t", "program_enrolled_t", "gagne_sum_t", "cost_t", "cost_avoidable_t",
                "bps_mean_t", "ghba1c_mean_t", "hct_mean_t", "cre_mean_t", "ldl_mean_t")
inputs <- setdiff(names(hs), c(outcomes_t, "race"))   # the year before, without race
```
