## code to prepare `foot_traffic` dataset goes here

## Source: City of Melbourne Open Data, Pedestrian Counting System
## (hourly counts and sensor locations), CC BY 4.0.

## The hourly counts are published as a rolling two-year window, so this script keeps a fixed 12 months (1 Oct 2025 to 30 Sep 2026). Re-running it
## reproduces the package data while that period is still in the published window (until about October 2027).

options(timeout = 600)

start_date <- as.Date("2025-10-01")
end_date   <- as.Date("2026-09-30")

counts_url <- paste0(
  "https://data.melbourne.vic.gov.au/api/explore/v2.1/catalog/datasets/",
  "pedestrian-counting-system-monthly-counts-per-hour/exports/csv?delimiter=%2C"
)
sensors_url <- paste0(
  "https://data.melbourne.vic.gov.au/api/explore/v2.1/catalog/datasets/",
  "pedestrian-counting-system-sensor-locations/exports/csv?delimiter=%2C"
)

# Download the raw files into data-raw/ (ignored by git because of their size)
download.file(counts_url, "data-raw/hourly_counts.csv")
download.file(sensors_url, "data-raw/sensor_locations.csv")

# Keep outdoor street sensors only. All 34 indoor sensors sit inside council facilities (libraries, community hubs), not retail areas.
sensors_outdoor <- readr::read_csv("data-raw/sensor_locations.csv", show_col_types = FALSE) |>
  janitor::clean_names() |>
  dplyr::filter(location_type == "Outdoor")

counts <- readr::read_csv("data-raw/hourly_counts.csv", show_col_types = FALSE) |>
  janitor::clean_names() |>
  dplyr::filter(sensing_date >= start_date, sensing_date <= end_date) |>
# Drop sensors with no matching location (e.g. 28 and 78): they can't be named or mapped
  dplyr::semi_join(sensors_outdoor, by = "location_id") |>
  dplyr::select(
    location_id, sensing_date,
    hour = hourday, count = pedestriancount
  )

# How many days each sensor actually reported in the window
coverage <- counts |>
  dplyr::group_by(location_id) |>
  dplyr::summarise(days_observed = dplyr::n_distinct(sensing_date))

# Average hourly count for each sensor, month, weekday and hour
foot_traffic <- counts |>
  dplyr::mutate(
    month   = lubridate::month(sensing_date, label = TRUE),
    weekday = lubridate::wday(sensing_date, label = TRUE, week_start = 1)
  ) |>
  dplyr::group_by(location_id, month, weekday, hour) |>
  dplyr::summarise(
    avg_count = round(mean(count), 1),
    n_obs     = dplyr::n(),
    .groups   = "drop"
  )

sensors <- sensors_outdoor |>
  dplyr::inner_join(coverage, by = "location_id") |>
  dplyr::select(
    location_id,
    location_name = sensor_description,
    latitude, longitude, installation_date, days_observed
  )

usethis::use_data(foot_traffic, sensors, overwrite = TRUE)