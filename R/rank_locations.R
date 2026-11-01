#'#' Rank street locations by foot traffic during trading hours
#'
#' Averages pedestrian counts at each sensor over the chosen trading days,
#' hours and months, then ranks the sensors from busiest to quietest. Use it
#' to compare candidate pop-up locations for the times the shop would
#' actually be open, rather than across the whole day.
#' 
#' @param data Average hourly foot traffic, in the format of [foot_traffic].
#' @param locations Sensor details, in the format of [sensors].
#' @param days Days the shop will trade, as three-letter abbreviations such as
#'   `c("Sat", "Sun")`.
#' @param hours Opening and closing time on the 24-hour clock. `c(10, 18)`
#'   means 10am to 6pm, so the last hour counted is 5pm to 6pm.
#' @param months Months to include, as three-letter abbreviations such as
#'   `c("Nov", "Dec")`. Defaults to all twelve.
#' @param min_days Minimum number of days a sensor must have reported in the
#'   year for its average to be treated as reliable. Defaults to 292, which is
#'   80% of the year.
#'
#' @return A tibble with one row per sensor, busiest first, with columns
#'   `rank`, `location_id`, `location_name`, `avg_per_hour` (average
#'   pedestrians per hour during the trading window), `hours_observed`
#'   (number of hourly readings behind that average), `days_observed`
#'   (days the sensor reported in the year), `limited_data` (`TRUE` when
#'   `days_observed` is below `min_days`, so the average should be read with
#'   caution), `latitude` and `longitude`.
#'
#' @importFrom dplyr filter group_by summarise left_join arrange desc mutate
#'   row_number select
#' @export
#'
#' @examples
#' # Weekend trading, 10am to 6pm, all year
#' rank_locations(foot_traffic, sensors, days = c("Sat", "Sun"))
#'
#' # Weekday lunch trade in the Christmas season
#' rank_locations(
#'   foot_traffic, sensors,
#'   days = c("Mon", "Tue", "Wed", "Thu", "Fri"),
#'   hours = c(11, 15),
#'   months = c("Nov", "Dec")
#' )
rank_locations <- function(data, locations, days, hours = c(10, 18),
                           months = month.abb, min_days = 292) {
  if (length(days) == 0) {
    stop("Choose at least one trading day.")
  }
  if (length(hours) != 2 || hours[1] >= hours[2]) {
    stop("`hours` must be an opening time followed by a later closing time, for example c(10, 18).")
  }
  
  data |>
    filter(
      weekday %in% days,
      month %in% months,
      hour >= hours[1],
      hour < hours[2]
    ) |>
    group_by(location_id) |>
    # Weight each average by the readings behind it, so the result is the
    # true average hourly count across the whole trading window
    summarise(
      avg_per_hour   = round(sum(avg_count * n_obs) / sum(n_obs)),
      hours_observed = sum(n_obs),
      .groups        = "drop"
    ) |>
    left_join(locations, by = "location_id") |>
    arrange(desc(avg_per_hour)) |>
    mutate(
      rank = row_number(),
      limited_data = days_observed < min_days
    ) |>
    select(rank, location_id, location_name, avg_per_hour,
           hours_observed, days_observed, limited_data,
           latitude, longitude)
}
