# SERVER
server <- function(input, output) {
  
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
  
  # Plot ------------------------------------------------------------------
  output$plot <- renderPlot(
    ggplot(data = dat, aes_string(x = input$x, y = input$y)) +
      geom_point()
  )
}
