# UI
ui <- function(request) {
  tagList(
    # UI hacks for bookmarking
    useShinyjs(),
    extendShinyjs(text = jscode, functions = c()),
    hidden(textInput("url_search", NULL, value = "")),
    hidden(textInput("url_origin", NULL, value = "")),
    tags$head(tags$script("
      Shiny.addCustomMessageHandler('updateInputs', function(params) {
        for (var id in params) {
          var $el = $('#' + id);
          if ($el.length) {
            var binding = $el.data('shiny-input-binding');
            if (binding) {
              binding.setValue($el[0], params[id]);
              $el.trigger('change');
            }
          }
        }
      });
    ")),
    page_navbar(id = "tabs",
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
                    actionButton("._bookmark_", label = "Bookmark...",
                                 icon = shiny::icon("link", lib = "glyphicon"),
                                 title = "Bookmark this application's state and get a URL for sharing.")
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
  )
}
