# UI
ui <- page_navbar(
  theme = my_theme,
  title = "BES Hackathon",
  fillable_mobile = TRUE,
  nav_panel("Plot", 
            plotOutput("plot")
            ),
  nav_panel("Table",
            dataTableOutput("table")
            ),
  nav_panel("About",
            p("This is text providing information :)")
            ),
  nav_spacer(),
  nav_item(
    input_dark_mode(mode = "light")
  ),
  sidebar = sidebar(
    selectInput(
      inputId = 'x', 
      label = 'X-axis', 
      choices = colnames(dat), 
      selected = "year_published"
      ), 
    selectInput(
      inputId = 'y', 
      label = 'Y-axis', 
      choices = colnames(dat), 
      selected = "paper_number"
      ),
    selectInput(
      inputId = 'colour', 
      label = 'Colour', 
      choices = colnames(dat), 
      selected = "journal"
      ),
    selectInput(
      inputId = 'facet_row', 
      label = 'Facet Row',
      choices = c(None='.', colnames(dat))
      ),
    selectInput(inputId = 'facet_col', 
                label = 'Facet Column',
                choices = c(None='.', colnames(dat))
                ),
    checkboxInput(
      inputId = 'jitter', 
      label = 'Jitter', 
      value = FALSE
      ),
    checkboxInput(
      inputId = 'smooth', 
      label = 'Smooth', 
      value = FALSE
      ),
    )
)
