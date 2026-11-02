# Hour-by-hour foot traffic for chosen locations

Averages pedestrian counts for each hour of the day at the chosen
sensors, over the trading days and months selected. Use it to see when a
location is busiest and whether that peak falls inside your opening
hours.

## Usage

``` r
hourly_profile(data, locations, location_ids, days, months = month.abb)
```

## Arguments

- data:

  Average hourly foot traffic, in the format of
  [foot_traffic](https://etc5523-2026.github.io/etc5523-assignment-4-anan0016-collab/reference/foot_traffic.md).

- locations:

  Sensor details, in the format of
  [sensors](https://etc5523-2026.github.io/etc5523-assignment-4-anan0016-collab/reference/sensors.md).

- location_ids:

  Sensor identifiers to include, for example the top three from
  [`rank_locations()`](https://etc5523-2026.github.io/etc5523-assignment-4-anan0016-collab/reference/rank_locations.md).

- days:

  Days to include, as three-letter abbreviations such as
  `c("Sat", "Sun")`.

- months:

  Months to include, as three-letter abbreviations. Defaults to all
  twelve.

## Value

A tibble with one row per sensor and hour, with columns `location_id`,
`hour` (0 to 23), `avg_per_hour` (average pedestrians in that hour) and
`location_name`.

## Examples

``` r
# Weekend pattern at the top three weekend locations
top3 <- rank_locations(foot_traffic, sensors, days = c("Sat", "Sun"))$location_id[1:3]
hourly_profile(foot_traffic, sensors, top3, days = c("Sat", "Sun"))
#> # A tibble: 72 × 4
#>    location_id  hour avg_per_hour location_name   
#>          <dbl> <dbl>        <dbl> <chr>           
#>  1           4     0          776 Town Hall (West)
#>  2           4     1          464 Town Hall (West)
#>  3           4     2          297 Town Hall (West)
#>  4           4     3          190 Town Hall (West)
#>  5           4     4          100 Town Hall (West)
#>  6           4     5           84 Town Hall (West)
#>  7           4     6          124 Town Hall (West)
#>  8           4     7          209 Town Hall (West)
#>  9           4     8          435 Town Hall (West)
#> 10           4     9          952 Town Hall (West)
#> # ℹ 62 more rows
```
