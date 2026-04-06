# UI
ui <- function(request) {
  tagList(
    # UI hacks for bookmarking
    useShinyjs(),
    extendShinyjs(text = jscode, functions = c()),
    hidden(textInput("url_search", NULL, value = "")),
    hidden(textInput("url_origin", NULL, value = "")),
    tags$head(
      tags$script(HTML("
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
      tags$script(HTML("
        function adjustDTHeight(settings) {
          var $wrapper = $(settings.nTableWrapper);
          var $scrollBody = $wrapper.find('.dataTables_scrollBody');
          var wh = window.innerHeight;
          var topOffset = $scrollBody.offset().top;
          var $info = $wrapper.find('.dataTables_info');
          var bottomChrome = $info.length ? $info.outerHeight(true) : 0;
          var padding = 10;
          var newHeight = wh - topOffset - bottomChrome - padding;
          $scrollBody.css('max-height', newHeight + 'px');
          if (settings.oScroller) {
            settings.oScroller.dom.scroller.style.height = newHeight + 'px';
            settings.oScroller.measure();
          }
        }
      
        $(document).on('init.dt', function(e, settings) {
          adjustDTHeight(settings);
          $(window).on('resize', function() {
            adjustDTHeight(settings);
          });
        });
      ")),
    ),
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
                      inputId = 'geom', 
                      label = 'Plot type', 
                      choices = c(None = '.', 
                                  Bar = "geom_bar", 
                                  Boxplot = "geom_boxplot",
                                  Line = "geom_line",
                                  Point = "geom_point")
                    ),
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
                    accordion(
                      id = "plot_accordion",
                      open = FALSE,
                      accordion_panel(
                        span(
                          "Colours ",
                          tooltip(
                            icon("info-circle"),
                            "Choose variables to colour or fill the plot by."
                          )
                        ),
                        value = "colour",
                        selectInput(
                          inputId = 'colour', 
                          label = 'Colour by', 
                          choices = c(None='.', colnames(dat))
                        ),
                        hidden(checkboxInput(
                          inputId = "exclude_na_colour",
                          label = "Exclude NA from colour",
                          value = FALSE
                        )),
                        selectInput(
                          inputId = 'fill', 
                          label = 'Fill by', 
                          choices = c(None='.', colnames(dat))
                        ),
                        hidden(checkboxInput(
                          inputId = "exclude_na_fill",
                          label = "Exclude NA from fill",
                          value = FALSE
                        )),
                      ),
                      accordion_panel(
                        span(
                          "Facetting ",
                          tooltip(
                            icon("info-circle"),
                            paste("Choose variables to facet the plot by.",
                                  "Facetting creates separate subplots for",
                                  "each level of the chosen variable(s).")
                          )
                        ),
                        value = "facet",
                        selectInput(
                          inputId = 'facet_row', 
                          label = 'Facet row by',
                          choices = c(None='.', colnames(dat))
                        ),
                        selectInput(
                          inputId = 'facet_col', 
                          label = 'Facet column by',
                          choices = c(None='.', colnames(dat))
                        ),
                      ),
                      accordion_panel(
                        span(
                          "Filters ",
                          tooltip(
                            icon("info-circle"),
                            paste("Add filters to subset the data. You can",
                                  "add multiple filters and they will be",
                                  "combined with AND logic.")
                          )
                        ),
                        value = "filters",
                        div(id = "filter_container"),
                        actionButton("add_filter", "Add filter", 
                                     icon = icon("plus"))
                      )
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
