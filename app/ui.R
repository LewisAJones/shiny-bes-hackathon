# UI
ui <- page_navbar(
  theme = my_theme,
  title = "BES Hackathon",
  fillable_mobile = TRUE,
  nav_panel("About",
            p("This is text providing information :)")
  ),
  nav_panel("Plot", 
            layout_sidebar(
              sidebar = sidebar(
                selectInput(
                  inputId = 'x', 
                  label = 'X-axis variable', 
                  choices = c(None='.', colnames(dat))
                ), 
                selectInput(
                  inputId = 'y', 
                  label = 'Y-axis variable', 
                  choices = c(None='.', colnames(dat))
                ),
                selectInput(
                  inputId = 'geom', 
                  label = 'Plot type', 
                  choices = c(None = '.', 
                              Bar = "geom_bar", 
                              Boxplot = "geom_boxplot",
                              Line = "geom_line",
                              Point = "geom_point")
                ), 
                selectInput(
                  inputId = 'colour', 
                  label = 'Colour by', 
                  choices = c(None='.', colnames(dat))
                ),
                selectInput(
                  inputId = 'fill', 
                  label = 'Fill by', 
                  choices = c(None='.', colnames(dat))
                ),
                selectInput(
                  inputId = 'facet_row', 
                  label = 'Facet row by',
                  choices = c(None='.', colnames(dat))
                ),
                selectInput(inputId = 'facet_col', 
                            label = 'Facet column by',
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
              ),
              plotOutput("plot")
            )
            ),
  nav_panel("Table",
            dataTableOutput("table")
            ),
  nav_spacer(),
  nav_item(
    input_dark_mode(mode = "light")
  )
)
