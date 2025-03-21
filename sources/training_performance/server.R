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

    load_all_paths()


    observeEvent(input$load_data, {
        updateSelectizeInput(session, "select", choices = get_files(), server = TRUE)
    })

    observeEvent(input$load_all, {
        load_all_paths()
    })


    observeEvent(input$selected_location, {
        nav_select("tabs", "Analysis")
        output$analysis_result <- renderText({
            paste("Performing analysis for:", input$selected_location)
        })
    })
}

# Create Shiny app ----
# shinyApp(ui = ui, server = server)
# runApp(appDir = "/Users/tommasobertola/Git/TrainingPerformances/sources/training_performance", launch.browser = TRUE)
