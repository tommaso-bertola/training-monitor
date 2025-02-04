library(shiny)
library(leaflet)
library(leaflet.extras)

ui <- fluidPage(
  leafletOutput("map"),
  actionButton("clear", "Clear Drawings"),
  tableOutput("points_table")
)

server <- function(input, output, session) {
  # Reactive data frame to store drawn points
  points_df <- reactiveVal(data.frame(lat = numeric(), lng = numeric()))

  # Render the leaflet map with drawing tools
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      fitBounds(
        11, 44,
        12, 45
      ) %>%
      addDrawToolbar(
        targetGroup = "drawnItems",
        polylineOptions = FALSE,
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
        overlayGroups = c("drawnItems"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })

  # Observe drawing creation
  observeEvent(input$map_draw_new_feature, {
    feature <- input$map_draw_new_feature

    # Extract coordinates if it's a marker
    if (feature$geometry$type == "Point") {
      coords <- feature$geometry$coordinates
      new_point <- data.frame(lat = coords[[2]], lng = coords[[1]])
      # Add to reactive data frame
      updated_points <- rbind(points_df(), new_point)
      points_df(updated_points)
    }
  })

  # Clear drawings
  observeEvent(input$clear, {
    points_df(data.frame(lat = numeric(), lng = numeric())) # Reset data frame
    leafletProxy("map") %>% clearGroup("drawnItems") # Clear drawings on the map
  })

  # Display captured points in a table
  output$points_table <- renderTable({
    points_df()
  })
}

shinyApp(ui, server)
