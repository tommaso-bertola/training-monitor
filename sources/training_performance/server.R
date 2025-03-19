library(shiny)
library(bslib)
library(RColorBrewer)

source("/Users/tommasobertola/Git/TrainingPerformances/sources/training_performance/utils.R")
# Define server logic required to draw a histogram ----
server <- function(input, output, session) {
    output$map <- renderLeaflet({
        leaflet() %>%
            addTiles() %>%
            fitBounds(
                11.3, 45.3,
                11.7, 45.7
            ) %>%
            addDrawToolbar(
                targetGroup = "Paths and points",
                polylineOptions = TRUE,
                polygonOptions = FALSE,
                circleOptions = FALSE,
                rectangleOptions = FALSE,
                markerOptions = TRUE,
                circleMarkerOptions = FALSE,
                editOptions = editToolbarOptions(
                    selectedPathOptions = selectedPathOptions()
                )
            ) %>%
            addLayersControl(
                overlayGroups = c("Paths and points"),
                options = layersControlOptions(collapsed = FALSE)
            )
    })

    observeEvent(input$load_data, {
        updateSelectizeInput(session, "select", choices = get_files(), server = TRUE)
    })

    observeEvent(input$load_all, {
        color_list <- brewer.pal(10, "Paired")
        # Recycle colors for 100 elements
        num_elements <- 100
        recycled_colors <- rep(color_list, length.out = num_elements)
        filenames <- get_files()
        for (i in 1:length(filenames)) {
            filename <- filenames[[i]]
            cat("Loading file", i, "of", length(filenames), "\n")
            trackpoint_data <- read_gpx_strava(filename)
            leafletProxy("map") %>%
                addPolylines(
                    data = trackpoint_data,
                    lat = ~Latitude, lng = ~Longitude,
                    label = basename(filename),
                    color = recycled_colors[i],
                    opacity = 0.5, weight = 5
                )
            cat(recycled_colors[i], "\n")
            icons <- awesomeIcons(
                icon = "fa-flag-checkered",
                iconColor = "#c56969",
                library = "fa"
            )
            iconSet <- awesomeIconList(
                home = makeAwesomeIcon(icon = "Home", library = "fa"),
                flag = makeAwesomeIcon(icon = "Flag", library = "fa")
            )
            oceanIcons <- iconList(
                ship = makeIcon(
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Maki2-ferry-18.svg/480px-Maki2-ferry-18.svg.png",
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Maki2-ferry-18.svg/18px-Maki2-ferry-18.svg.png",
                    18,
                    18
                ),
                pirate = makeIcon(
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Maki2-danger-24.svg/240px-Maki2-danger-24.svg.png",
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Maki2-danger-24.svg/24px-Maki2-danger-24.svg.png",
                    24,
                    24
                )
            )

            leafletProxy("map") %>%
                addMarkers(
                    data = trackpoint_data[1, ],
                    lat = ~Latitude, lng = ~Longitude,
                    icon = oceanIcons$pirate,
                    label = paste0("Start: ", basename(filename))
                )
        }
    })
}

# Create Shiny app ----
# shinyApp(ui = ui, server = server)
# runApp(appDir = "/Users/tommasobertola/Git/TrainingPerformances/sources/training_performance", launch.browser = TRUE)
