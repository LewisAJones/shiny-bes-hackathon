# SERVER
server <- function(input, output) {
  
  # Plot ------------------------------------------------------------------
  output$plot <- renderPlot({
    p <- ggplot(data = dat, aes(x = .data[[input$x]], y = .data[[input$y]])) +
      geom_point()
    
    if (input$colour != 'None') p <- p + aes(colour = .data[[input$colour]])
    
    facets <- paste(input$facet_row, '~', input$facet_col)
    
    if (facets != '. ~ .') p <- p + facet_grid(facets)
    
    if (input$jitter) p <- p + geom_jitter()
    if (input$smooth) p <- p + geom_smooth()
    
    p
  })
  
  # Table -----------------------------------------------------------------
  output$table <- renderDataTable(
    dat,
    extensions = c("Responsive", "Scroller"),
    options = list(
      deferRender = TRUE,
      scrollY = 800,
      scroller = TRUE
    )
  )
  
}
