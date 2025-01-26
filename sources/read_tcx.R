library(xml2)
library(tidyverse)
library(ggplot2)
library(lubridate)
library(leaflet)

file_path <- list.files("data", pattern = "*.TCX|*.tcx", full.names = TRUE) # Replace with your actual file path
file_path <- file_path[1]

xml_data <- read_xml(file_path)
xml_ns_strip(xml_data)
ns <- xml_ns(xml_data)

trackpoints <- xml_find_all(xml_data, "//Trackpoint", ns)
latitude <- xml_find_first(trackpoints, ".//LatitudeDegrees", ns) %>%
    xml_text(trim = TRUE) %>%
    as.numeric()
time <- xml_find_first(trackpoints, ".//Time", ns) %>%
    xml_text(trim = TRUE) %>%
    as_datetime()
bpm <- xml_find_first(trackpoints, ".//HeartRateBpm/Value", ns) %>%
    xml_text(trim = TRUE) %>%
    as.numeric()
longitude <- xml_find_first(trackpoints, ".//LongitudeDegrees", ns) %>%
    xml_text(trim = TRUE) %>%
    as.numeric()

trackpoint_data <- data.frame(Time = time, Hr = bpm, Latitude = latitude, Longitude = longitude)

ggplot(trackpoint_data, aes(x = Time, y = Hr)) +
    geom_point(size = 0.4) +
    geom_line(group = 1) +
    labs(title = "Heart Rate Over Time", x = "Time", y = "Heart Rate (bpm)")


ggplot(trackpoint_data, aes(x = Longitude, y = Latitude)) +
    geom_point(size = 0.4) +
    geom_path(group = 1) +
    labs(title = "Route Map", x = "Longitude", y = "Latitude")


leaflet() %>%
    addTiles() %>%
    fitBounds(
        min(trackpoint_data$Longitude, na.rm = T) - 0.01, min(trackpoint_data$Latitude, na.rm = T) - 0.01,
        max(trackpoint_data$Longitude, na.rm = T) + 0.01, max(trackpoint_data$Latitude, na.rm = T) + 0.01
    ) %>%
    addPolylines(data = trackpoint_data, lat = ~Latitude, lng = ~Longitude, color = "#000000", opacity = 0.8, weight = 3)


# m %>% addPopups(-93.65, 42.0285, "Here is the <b>Department of Statistics</b>, ISU")
