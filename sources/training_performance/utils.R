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


utilsIcons <- iconList(
    start = makeIcon("https://img.icons8.com/ios-glyphs/30/empty-flag.png", iconWidth = 20, iconHeight = 20),
    end = makeIcon("https://img.icons8.com/ios-glyphs/30/finish-flag.png", iconWidth = 20, iconHeight = 20)
)

load_all_paths <- function() {
    color_list <- brewer.pal(10, "Paired")
    num_elements <- 100
    recycled_colors <- rep(color_list, length.out = num_elements)

    filenames <- get_files()
    
    for (i in 1:length(filenames)) {
        filename <- filenames[[i]]
        trackpoint_data <- read_gpx_strava(filename)
        leafletProxy("map") %>%
            addPolylines(
                data = trackpoint_data$data,
                lat = ~Latitude, lng = ~Longitude,
                popup = paste0('<a href="#" onclick="Shiny.setInputValue(\'selected_location\', \'', trackpoint_data$name, '\', {priority: \'event\'});">', trackpoint_data$name, "</a>"),
                color = recycled_colors[i],
                opacity = 0.8, weight = 5
            ) %>%
            addMarkers(
                data = trackpoint_data$data[1, ],
                lat = ~Latitude, lng = ~Longitude,
                icon = utilsIcons$start
            ) %>%
            addMarkers(
                data = trackpoint_data$data[nrow(trackpoint_data$data), ],
                lat = ~Latitude, lng = ~Longitude,
                icon = utilsIcons$end
            )
    }
    cat("Paths loaded\n")
}
