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
    p <- ggplot(data = dataset(), aes(x = .data[[input$x]], y = .data[[input$y]])) +
      geom_point()
    
    if (input$colour != 'None') p <- p + aes(colour = .data[[input$colour]])
    
    facets <- paste(input$facet_row, '~', input$facet_col)
    
    if (facets != '. ~ .') p <- p + facet_grid(facets)
    
    if (input$jitter) p <- p + geom_jitter()
    if (input$smooth) p <- p + geom_smooth()
    
    p
  })
  
  # Table -----------------------------------------------------------------
  output$table <- renderDT(
    dataset(),
    extensions = c("Scroller"),
    options = list(
      deferRender = TRUE,
      scrollY = 800,
      scroller = TRUE
    ),
    filter = list(
      position = 'top'
    ),
    escape = FALSE
  )
  
}
