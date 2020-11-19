
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tfnswapi

<!-- badges: start -->

[![R build
status](https://github.com/asiripanich/tfnswapi/workflows/R-CMD-check/badge.svg)](https://github.com/asiripanich/tfnswapi/actions)
<!-- badges: end -->

<p align="center">

<img src="https://pbs.twimg.com/media/DadjxdeUwAA5Uxb?format=jpg&name=medium" />

</p>

The goal of tfnswapi is to provide an easy way for R users to download
data from [TfNSW Open Data](https://opendata.transport.nsw.gov.au/).

## Installation

You can install the `tfnswapi` package from
[GitHub](https://github.com/asiripanich/tfnswapi) with:

``` r
install.packages("tfnswapi")
```

## Examples

### Carpark API

``` r
library(tfnswapi)
# See what facilities are available

# remove `if (FALSE)` to register your own API key
if (FALSE) {
  tfnswapi_register("<your-api-key>")
}

carparks = tfnswapi_get("carpark")
#> No encoding supplied: defaulting to UTF-8.
carpark_ids = names(carparks$content)
names(carpark_ids) = carparks$content 
carpark_ids
#>        Tallawong Station Car Park       Kellyville Station Car Park 
#>                               "1"                               "2" 
#>      Bella Vista Station Car Park Hills Showground Station Car Park 
#>                               "3"                               "4" 
#>                          Ashfield                           Kogarah 
#>                             "486"                             "487" 
#>                       Seven hills       SYD326 Manly Vale Park Ride 
#>                             "488"                             "489" 
#>      Cherrybrook Station Car Park 
#>                               "5"

# get data of just one carpark
carpark = tfnswapi_get("carpark", params = list(facility = 2))
#> No encoding supplied: defaulting to UTF-8.
tidied_carpark = data.frame(
  zone_id = purrr::map_chr(carpark$content$zones, purrr::pluck("zone_id")),
  total_spots = purrr::map_chr(carpark$content$zones, purrr::pluck("spots")),
  free_spots = purrr::map_chr(carpark$content$zones, purrr::pluck(list("occupancy", "total")))
)

library(ggplot2)
ggplot(data = tidied_carpark, aes(x = zone_id)) +
  geom_col(aes(y = as.integer(total_spots)), fill = "grey60", alpha = 0.8) +
  geom_col(aes(y = as.integer(free_spots)), fill = "#009E73") +
  labs(
    title = paste("Available parking spots at", carpark$content$facility_name),
    subtitle = carpark$content$MessageDate,
    y = "# Spots"
  )
```

<img src="man/figures/README-carpark-example-1.png" width="100%" />
\#\#\# GTFS Realtime API

See TfNSW GTFS Realtime documentation
[here](https://opendata.transport.nsw.gov.au/sites/default/files/TfNSW_GTFS_Realtime_Buses_Technical_Doc.pdf).

``` r
library(tfnswapi)
library(ggplot2)
library(ggmap)
library(sf)

# remove `if (FALSE)` to register your own API key
if (FALSE) {
  tfnswapi_register("<your-api-key>")
}

bus_response = tfnswapi_get("gtfs/vehiclepos/buses")
bus_position_table = bus_response$content$entity$vehicle$position

bus_position_table = 
  bus_position_table %>%
  sf::st_as_sf(coords = c("longitude", "latitude")) %>%
  sf::st_set_crs(value = sf::st_crs("WGS84"))

# Convert momentary speed measured by the vehicle in meters per second to
# kilometers per hour
bus_position_table$speed = 3.6 * bus_position_table$speed

# get base map
sydney_bbox = sf::st_geometry(bus_position_table) %>% sf::st_bbox()
names(sydney_bbox) <- c("left", "bottom", "right", "top")
sydney_map = get_stamenmap(sydney_bbox, maptype = "toner-lite", messaging = FALSE)

ggmap(sydney_map) +
  coord_sf(crs = sf::st_crs("WGS84")) +
  geom_sf(data = bus_position_table, aes(color = speed), inherit.aes = FALSE) +
  labs(title = "Realtime positions of buses in Sydney, Australia",
       color = "Speed (km/hr)",
       subtitle = bus_response$date)
```

<img src="man/figures/README-gtfsr-example-1.png" width="100%" />
