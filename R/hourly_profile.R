#' Hour-by-hour foot traffic for chosen locations
#'
#' Averages pedestrian counts for each hour of the day at the chosen sensors,
#' over the trading days and months selected. Use it to see when a location
#' is busiest and whether that peak falls inside your opening hours.
#'
#' @param data Average hourly foot traffic, in the format of [foot_traffic].
#' @param locations Sensor details, in the format of [sensors].
#' @param location_ids Sensor identifiers to include, for example the top
#'   three from [rank_locations()].
#' @param days Days to include, as three-letter abbreviations such as
#'   `c("Sat", "Sun")`.
#' @param months Months to include, as three-letter abbreviations. Defaults to
#'   all twelve.
#'
#' @return A tibble with one row per sensor and hour, with columns
#'   `location_id`, `hour` (0 to 23), `avg_per_hour` (average pedestrians in
#'   that hour) and `location_name`.
#'
#' @importFrom dplyr filter group_by summarise left_join select
#' @export
#'
#' @examples
#' # Weekend pattern at the top three weekend locations
#' top3 <- rank_locations(foot_traffic, sensors, days = c("Sat", "Sun"))$location_id[1:3]
#' hourly_profile(foot_traffic, sensors, top3, days = c("Sat", "Sun"))
hourly_profile <- function(data, locations, location_ids, days,
                           months = month.abb) {
  if (length(days) == 0) {
    stop("Choose at least one trading day.")
  }
  
  data |>
    filter(
      location_id %in% location_ids,
      weekday %in% days,
      month %in% months
    ) |>
    group_by(location_id, hour) |>
    summarise(
      avg_per_hour = round(sum(avg_count * n_obs) / sum(n_obs)),
      .groups = "drop"
    ) |>
    left_join(select(locations, location_id, location_name),
              by = "location_id")
}