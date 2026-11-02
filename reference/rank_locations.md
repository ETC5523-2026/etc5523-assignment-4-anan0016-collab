# \#' Rank street locations by foot traffic during trading hours

Averages pedestrian counts at each sensor over the chosen trading days,
hours and months, then ranks the sensors from busiest to quietest. Use
it to compare candidate pop-up locations for the times the shop would
actually be open, rather than across the whole day.

## Usage

``` r
rank_locations(
  data,
  locations,
  days,
  hours = c(10, 18),
  months = month.abb,
  min_days = 292
)
```

## Arguments

- data:

  Average hourly foot traffic, in the format of
  [foot_traffic](https://etc5523-2026.github.io/etc5523-assignment-4-anan0016-collab/reference/foot_traffic.md).

- locations:

  Sensor details, in the format of
  [sensors](https://etc5523-2026.github.io/etc5523-assignment-4-anan0016-collab/reference/sensors.md).

- days:

  Days the shop will trade, as three-letter abbreviations such as
  `c("Sat", "Sun")`.

- hours:

  Opening and closing time on the 24-hour clock. `c(10, 18)` means 10am
  to 6pm, so the last hour counted is 5pm to 6pm.

- months:

  Months to include, as three-letter abbreviations such as
  `c("Nov", "Dec")`. Defaults to all twelve.

- min_days:

  Minimum number of days a sensor must have reported in the year for its
  average to be treated as reliable. Defaults to 292, which is 80% of
  the year.

## Value

A tibble with one row per sensor, busiest first, with columns `rank`,
`location_id`, `location_name`, `avg_per_hour` (average pedestrians per
hour during the trading window), `hours_observed` (number of hourly
readings behind that average), `days_observed` (days the sensor reported
in the year), `limited_data` (`TRUE` when `days_observed` is below
`min_days`, so the average should be read with caution), `latitude` and
`longitude`.

## Examples

``` r
# Weekend trading, 10am to 6pm, all year
rank_locations(foot_traffic, sensors, days = c("Sat", "Sun"))
#> # A tibble: 100 × 9
#>     rank location_id location_name     avg_per_hour hours_observed days_observed
#>    <int>       <dbl> <chr>                    <dbl>          <int>         <int>
#>  1     1           4 Town Hall (West)          3291            816           363
#>  2     2          41 Flinders La-Swan…         2966            832           363
#>  3     3          66 QV2 Apartments, …         2459            816           363
#>  4     4          35 Southbank Promen…         2418            832           365
#>  5     5           5 Princes Bridge            2349            832           365
#>  6     6           1 Bourke Street Ma…         2338            304           134
#>  7     7           3 Melbourne Central         2310            832           365
#>  8     8          84 Elizabeth St - F…         1980            832           365
#>  9     9         184 124 Elizabeth St…         1976            832           365
#> 10    10          47 Melbourne Centra…         1898            832           365
#> # ℹ 90 more rows
#> # ℹ 3 more variables: limited_data <lgl>, latitude <dbl>, longitude <dbl>

# Weekday lunch trade in the Christmas season
rank_locations(
  foot_traffic, sensors,
  days = c("Mon", "Tue", "Wed", "Thu", "Fri"),
  hours = c(11, 15),
  months = c("Nov", "Dec")
)
#> # A tibble: 100 × 9
#>     rank location_id location_name     avg_per_hour hours_observed days_observed
#>    <int>       <dbl> <chr>                    <dbl>          <int>         <int>
#>  1     1           4 Town Hall (West)          3223            172           363
#>  2     2          41 Flinders La-Swan…         2839            172           363
#>  3     3         184 124 Elizabeth St…         2293            172           365
#>  4     4           1 Bourke Street Ma…         2155             20           134
#>  5     5          35 Southbank Promen…         2115            172           365
#>  6     6           2 Bourke Street Ma…         2062            172           365
#>  7     7          84 Elizabeth St - F…         2023            172           365
#>  8     8          66 QV2 Apartments, …         1948            172           363
#>  9     9           3 Melbourne Central         1889            172           365
#> 10    10          47 Melbourne Centra…         1713            172           365
#> # ℹ 90 more rows
#> # ℹ 3 more variables: limited_data <lgl>, latitude <dbl>, longitude <dbl>
```
