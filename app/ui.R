# UI
ui <- page_navbar(
  theme = my_theme,
  title = "BES Hackathon",
  fillable_mobile = TRUE,
  nav_panel("Table",
            dataTableOutput("table")),
  nav_panel("Plot", 
            plotOutput("plot")),
  nav_spacer(),
  nav_item(
    input_dark_mode(mode = "light")
  ),
  sidebar = sidebar(
    selectInput(
      inputId = 'x', 
      label = 'X', 
      choices = colnames(dat), 
      selected = colnames(dat)[[3]]
      ), 
    selectInput(
      inputId = 'y', 
      label = 'Y', 
      choices = colnames(dat), 
      selected = colnames(dat)[[1]]
      )
    )
)
