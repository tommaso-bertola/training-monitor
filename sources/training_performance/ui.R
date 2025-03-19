library(shiny)
library(bslib)
library(ggplot2)
library(leaflet)
library(leaflet.extras)

ui <- page_sidebar(
    theme = bs_theme(version = 5),
    title = "Training Performance",
    sidebar = sidebar(
        bg = "white",
        accordion(
            accordion_panel(
                "Select data",
                selectizeInput(
                    "select",
                    "Load file:",
                    choices = NULL,
                    multiple = TRUE
                ),
            ),
            actionButton("save_button", "Save", class = "btn-primary"),
            actionButton("load_data", "Load Options", class = "btn-primary"),
            actionButton("load_to_map", "Load into Map", class = "btn-primary"),
            actionButton("load_all", "Load all paths", class = "btn-primary")
        )
    ),
    navset_tab(
        nav_panel("Map", leafletOutput("map", width = "100%", height = 800))
    ),
    # accordion(
    #     open = c("Map"),
    #     accordion_panel(
    #         "Map",
    #         leafletOutput("map")
    #     ),
    #     accordion_panel(
    #         "Speed",
    #     ),
    #     accordion_panel(
    #         "Heart Rate",
    #     )
    # )
)
