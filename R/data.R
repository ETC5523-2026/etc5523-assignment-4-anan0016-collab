#' Average hourly foot traffic at Melbourne CBD street sensors
#'
#' Average pedestrian counts for each outdoor sensor in the City of Melbourne
#' Pedestrian Counting System, broken down by month, day of the week and hour.
#' Covers 1 October 2025 to 30 September 2026. One row is one sensor in one
#' month, on one weekday, in one hour of the day.
#' 
#' 
#' @format A tibble with 100 rows and 6 columns:
#' \describe{
#'   \item{location_id}{Sensor identifier. Joins to [sensors].}
#'   \item{month}{Month of the year (ordered factor, Jan to Dec).}
#'   \item{weekday}{Day of the week (ordered factor, Mon to Sun).}
#'   \item{hour}{Hour of the day, 0 to 23. For example, 14 means 2pm to 3pm.}
#'   \item{avg_count}{Average number of pedestrians passing the sensor in that
#'     hour, in people per hour.}
#'   \item{n_obs}{Number of hourly readings the average is based on. Lower
#'     values mean a less reliable average.}
#' }
#' 
#' @details Counts measure people walking past a sensor, not unique visitors
#'   or shoppers. Only the 100 outdoor street sensors are included: the 34
#'   indoor sensors are all inside council facilities such as libraries, so
#'   they do not reflect retail foot traffic. Sensors 28 and 78 were dropped
#'   because they have no published location. Hours where a sensor did not
#'   report are missing rather than zero, so they are not part of the average.
#'
#' @source City of Melbourne Open Data, Pedestrian Counting System (counts per
#'   hour), <https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-monthly-counts-per-hour/>.
#'   Licensed under CC BY 4.0.
"foot_traffic"
#' Melbourne CBD outdoor pedestrian sensor locations
#'
#' Name, location and data coverage for each outdoor pedestrian sensor in
#' [foot_traffic]. One row is one sensor.
#' 
#' @format A tibble with 195128 rows and 6 columns:
#' \describe{
#'   \item{location_id}{Sensor identifier. Joins to [foot_traffic].}
#'   \item{location_name}{Description of where the sensor is, for example
#'     "Melbourne Central".}
#'   \item{latitude}{Latitude in decimal degrees.}
#'   \item{longitude}{Longitude in decimal degrees.}
#'   \item{installation_date}{Date the sensor was installed.}
#'   \item{days_observed}{Number of days between 1 October 2025 and
#'     30 September 2026 on which the sensor reported counts.}
#' }
#'
#' @details Sensors are placed by the City of Melbourne based on retail and
#'   event activity and regular pedestrian use, so busy areas are better
#'   covered than quieter streets. A location without a sensor cannot be
#'   assessed.
#'
#' @source City of Melbourne Open Data, Pedestrian Counting System - Sensor
#'   Locations, <https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-sensor-locations/>.
#'   Licensed under CC BY 4.0.
"sensors"