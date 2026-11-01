#' @importFrom utils globalVariables
NULL

# Column names used inside dplyr verbs, declared so R CMD check
# doesn't mistake them for undefined variables
utils::globalVariables(c(
  "weekday", "month", "hour", "location_id", "avg_count", "n_obs",
  "avg_per_hour", "hours_observed", "location_name", "latitude", "longitude",
  "days_observed", "limited_data"
))