---
title: "Spotify tracks"
description: "10,000 tracks from Spotify playlists of six genres, with audio features, a release date and Spotify's popularity score. The week-5 task: what makes a song popular?"
---

| | |
|---|---|
| **Provenance and license** | Collected from the Spotify Web API by Kaylin Pavlik (January 2020) and published as the TidyTuesday dataset of 21 January 2020, 32,833 rows. Spotify's developer terms restrict commercial use; this is teaching. The course file is 10,000 tracks drawn at random from the 28,356 distinct tracks. |
| **R access** | `readr::read_csv("https://ml4ds.com/files/spotify_tracks.csv")`, then one row per `track_id` (the loader below). |
| **Unit of observation** | A track. The file has a row per track and playlist (11,554 rows), since 1,101 tracks are in more than one playlist. Columns: `track_id`, `track_name`, `track_artist`, `track_popularity` (0 to 100), `release_date`, `release_year`, `playlist_genre`, `playlist_subgenre`, and the audio features `danceability`, `energy`, `key`, `loudness`, `mode`, `speechiness`, `acousticness`, `instrumentalness`, `liveness`, `valence`, `tempo`, `duration_ms`. |
| **Target and loss** | `track_popularity` with squared error. Variance about 560; a tenth of the tracks score exactly 0. |
| **Available at prediction time** | The audio features and the release date are properties of the recording. The genre is the playlist's, not the track's. Popularity is Spotify's score in January 2020 and rewards recent plays, so `release_year` carries recency as well as era. |
| **Permitted predictors** | Week 5: the ten audio features (`duration_ms` in minutes), `release_year` and `playlist_genre`. |
| **Missingness** | None in the features; five tracks lack a name. |
| **Split unit and seed** | Tracks, with `set.seed(5)`: 5,000 training, 2,000 selection, 3,000 test. A split by row puts the same track on both sides (week 7's leakage example). |
| **Baseline** | The training mean, 39.1: MSE 581 on the selection tracks, where least squares on the eleven numeric inputs scores about 541 and $k$ nearest neighbors on the same inputs about 528. The test scores are the seminar's. |
| **Methods that use it** | Week 5: the lecture's demonstrations and the seminar's leaderboard. Week 7: cross-validation and the leakage check. |
| **Complication it carries** | The score is a snapshot of plays, not a judgment of the music; the playlists were one person's choice in one month. |
| **Limitations** | Six genres, no lyrics, no artist history, no play counts. Fine for the mechanism, not for a claim about music. |
| **Fictional?** | No. |

## Loader

```r
library(tidyverse)
sp <- read_csv("https://ml4ds.com/files/spotify_tracks.csv") |>
  distinct(track_id, .keep_all = TRUE) |>          # one row per track
  mutate(duration_min = duration_ms / 60000, genre = factor(playlist_genre))
```
