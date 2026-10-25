---
title: "Spotify tracks"
description: "10,000 tracks from Spotify playlists of six genres with twelve audio features, a release date and Spotify's popularity score. The week-5 task: what makes a song popular?"
---

| | |
|---|---|
| **Provenance and license** | Collected from the Spotify Web API by Kaylin Pavlik in January 2020 (the R package `spotifyr`, playlists of six genres and 24 subgenres) and published as the TidyTuesday dataset of 21 January 2020 (`rfordatascience/tidytuesday`, `data/2020/2020-01-21/spotify_songs.csv`, 32,833 rows). Spotify's developer terms restrict commercial use of API data; this is teaching, as with the IMDb data in the movies note. The course file is a subsample: 10,000 tracks drawn at random (Python, seed 310) from the 28,356 distinct `track_id` values, with every playlist row of each kept, 11,554 rows. |
| **R access** | `readr::read_csv("https://ml4ds.com/files/spotify_tracks.csv")`; the repository file is `files/spotify_tracks.csv` (1.8 MB). |
| **Unit of observation** | A track in a playlist. 1,101 of the 10,000 tracks appear in more than one playlist (up to ten in the full data), so the course's unit is the track and the loader keeps one row per `track_id`. Columns: `track_id`, `track_name`, `track_artist`, `track_popularity` (Spotify's score, 0 to 100), `release_date` (of the album; 1,855 rows in the full data have a year only), `release_year`, `playlist_genre` (six), `playlist_subgenre` (24), and the API's audio features `danceability`, `energy`, `key`, `loudness`, `mode`, `speechiness`, `acousticness`, `instrumentalness`, `liveness`, `valence`, `tempo`, `duration_ms`. |
| **Target and loss** | `track_popularity` with squared error. Its variance is about 560 (standard deviation 24), and about a tenth of the tracks score exactly 0, a value Spotify gives tracks that are rarely played (re-releases and obscure uploads among them). |
| **Available at prediction time** | The audio features and the release date are properties of the recording. The genre is a property of the playlist, not the track: 1,687 tracks in the full data sit in playlists of more than one genre, so the loader's genre is that of the first playlist listing. Popularity is Spotify's score at collection time (January 2020) and rewards recent plays, so `release_year` carries recency as well as era; a model fitted here predicts the 2020 score of a track, not a timeless quality. |
| **Permitted predictors** | Week 5: the eleven numeric features (`duration_ms` in minutes) and `playlist_genre`. `key` and `mode` are categorical and are left out of the splines; `instrumentalness` is 0 for most tracks and is used as a linear term or on a log scale. |
| **Missingness** | Five tracks in the full data lack a name; no feature is missing. |
| **Split unit and seed** | Tracks. The seminar splits the 10,000 tracks three ways with `set.seed(5)` into 5,000 training, 2,000 selection and 3,000 test tracks, so every student sees the same numbers. A split by row instead of by track puts the same track on both sides for about a tenth of the tracks (the leakage example of week 7). |
| **Baseline** | Predict the mean (39.1 on the training tracks): mean squared error 560 on the test tracks. Least squares on the eleven features and genre reaches about 519, an additive spline model about 484 and a random forest about 479, with a standard error of about 9.5 on the test set (the seminar's leaderboard; numbers from the seed above). |
| **Methods that use it** | Week 5: the three-way split and the baselines in the lecture; the seminar's leaderboard with least squares, k-NN, the lasso, an additive spline model, a tree and a forest. Week 7 reuses it for the cross-validation pipeline and the leakage check. |
| **Complication it carries** | The popularity score is a snapshot of plays, not a judgment of the music, and the playlists were chosen by one person in one month. The genre labels belong to playlists, which is why a track can carry two. The spike at 0 is a property of Spotify's scoring. |
| **Limitations** | Six genres, English and Spanish language playlists, no lyrics, no artist history, no play counts. Fine for the mechanism, which is the point in week 5, and for the question of which structure helps; not for a claim about music. |
| **Fictional?** | No. |

## Loader

```r
library(tidyverse)
sp <- read_csv("https://ml4ds.com/files/spotify_tracks.csv") |>
  distinct(track_id, .keep_all = TRUE) |>          # one row per track
  mutate(duration_min = duration_ms / 60000, genre = factor(playlist_genre))
```
