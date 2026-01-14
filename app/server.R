# SERVER
server <- function(input, output) {
  
  # Data ------------------------------------------------------------------
  dataset <- reactive({
    tmp <- dat
    tmp$doi <- paste0('<a href=\"https://doi.org/', tmp$doi,'" target="_blank">', tmp$doi ,"</a>")
    tmp
  })
  
  # Plot ------------------------------------------------------------------
  output$plot <- renderPlot({
    p <- ggplot(data = dataset()) +
      scale_colour_viridis_d() +
      scale_fill_viridis_d() +
      theme_bw()
    
    if (input$x != '.') p <- p + aes(x = .data[[input$x]])
    
    if (input$y != '.') p <- p + aes(y = .data[[input$y]])
    
    if (input$colour != '.') p <- p + aes(colour = .data[[input$colour]])
    
    if (input$fill != '.') p <- p + aes(fill = .data[[input$fill]])
    
    if (input$geom != '.') p <- p + get(input$geom)()
    
    facets <- paste(input$facet_row, '~', input$facet_col)
    
    if (facets != '. ~ .') p <- p + facet_grid(facets)
    
    if (input$jitter) p <- p + geom_jitter()
    if (input$smooth) p <- p + geom_smooth()
    
    p
  })
  
  # Table -----------------------------------------------------------------
  output$table <- renderDT(
    dataset(),
    extensions = c("Scroller", "KeyTable"),
    rownames = FALSE,
    options = list(
      deferRender = TRUE,
      scrollY = 710,
      scrollX = TRUE,
      scroller = TRUE,
      keys = TRUE
    ),
    filter = list(
      position = 'top'
    ),
    escape = FALSE,
    selection = 'none'
  )
  
}
