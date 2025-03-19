library(xml2)
library(tidyverse)
library(ggplot2)
library(lubridate)
library(leaflet)

get_files <- function() {
    files_vec <- list.files("/Users/tommasobertola/Git/TrainingPerformances/data/routes", full.names = TRUE, pattern = "*.gpx|*.GPX|*.tcx|*.TCX")
    files <- as.list(files_vec)
    names(files) <- basename(files_vec)
    return(files)
}


read_gpx_strava <- function(filename) {
    xml_data <- read_xml(filename)
    xml_ns_strip(xml_data)
    ns <- xml_ns(xml_data)
    trackpoints <- xml_find_all(xml_data, "//trkpt", ns)
    link <- xml_find_all(xml_data, "//trk/link", ns) %>%
        xml_attr("href")
    name <- xml_find_all(xml_data, "//trk/name", ns) %>%
        xml_text()
    altitude <- xml_find_first(trackpoints, ".//ele", ns) %>%
        xml_text(trim = TRUE) %>%
        as.numeric()
    latitude <- xml_find_first(trackpoints, ".//@lat", ns) %>%
        xml_text(trim = TRUE) %>%
        as.numeric()
    longitude <- xml_find_first(trackpoints, ".//@lon", ns) %>%
        xml_text(trim = TRUE) %>%
        as.numeric()
    trackpoint_data <- data.frame(Latitude = latitude, Longitude = longitude, Altitude = altitude)
    return(list(name = name, link = link, data = trackpoint_data))
}
