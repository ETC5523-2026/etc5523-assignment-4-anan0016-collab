# Average hourly foot traffic at Melbourne CBD street sensors

Average pedestrian counts for each outdoor sensor in the City of
Melbourne Pedestrian Counting System, broken down by month, day of the
week and hour. Covers 1 October 2025 to 30 September 2026. One row is
one sensor in one month, on one weekday, in one hour of the day.

## Usage

``` r
foot_traffic
```

## Format

A tibble with 100 rows and 6 columns:

- location_id:

  Sensor identifier. Joins to
  [sensors](https://etc5523-2026.github.io/etc5523-assignment-4-anan0016-collab/reference/sensors.md).

- month:

  Month of the year (ordered factor, Jan to Dec).

- weekday:

  Day of the week (ordered factor, Mon to Sun).

- hour:

  Hour of the day, 0 to 23. For example, 14 means 2pm to 3pm.

- avg_count:

  Average number of pedestrians passing the sensor in that hour, in
  people per hour.

- n_obs:

  Number of hourly readings the average is based on. Lower values mean a
  less reliable average.

## Source

City of Melbourne Open Data, Pedestrian Counting System (counts per
hour),
<https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-monthly-counts-per-hour/>.
Licensed under CC BY 4.0.

## Details

Counts measure people walking past a sensor, not unique visitors or
shoppers. Only the 100 outdoor street sensors are included: the 34
indoor sensors are all inside council facilities such as libraries, so
they do not reflect retail foot traffic. Sensors 28 and 78 were dropped
because they have no published location. Hours where a sensor did not
report are missing rather than zero, so they are not part of the
average.
