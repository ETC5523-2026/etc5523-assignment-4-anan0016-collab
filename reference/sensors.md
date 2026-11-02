# Melbourne CBD outdoor pedestrian sensor locations

Name, location and data coverage for each outdoor pedestrian sensor in
[foot_traffic](https://etc5523-2026.github.io/etc5523-assignment-4-anan0016-collab/reference/foot_traffic.md).
One row is one sensor.

## Usage

``` r
sensors
```

## Format

A tibble with 195128 rows and 6 columns:

- location_id:

  Sensor identifier. Joins to
  [foot_traffic](https://etc5523-2026.github.io/etc5523-assignment-4-anan0016-collab/reference/foot_traffic.md).

- location_name:

  Description of where the sensor is, for example "Melbourne Central".

- latitude:

  Latitude in decimal degrees.

- longitude:

  Longitude in decimal degrees.

- installation_date:

  Date the sensor was installed.

- days_observed:

  Number of days between 1 October 2025 and 30 September 2026 on which
  the sensor reported counts.

## Source

City of Melbourne Open Data, Pedestrian Counting System - Sensor
Locations,
<https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-sensor-locations/>.
Licensed under CC BY 4.0.

## Details

Sensors are placed by the City of Melbourne based on retail and event
activity and regular pedestrian use, so busy areas are better covered
than quieter streets. A location without a sensor cannot be assessed.
