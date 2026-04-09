# UI
ui <- function(request) {
  tagList(
    # UI hacks for bookmarking
    useShinyjs(),
    extendShinyjs(text = jscode, functions = c()),
    hidden(textInput("url_search", NULL, value = "")),
    hidden(textInput("url_origin", NULL, value = "")),
    hidden(textInput("url_hash", NULL, value = "")),
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
      tags$style(HTML("
        [data-bs-theme='dark'] .img-invert {
          filter: invert(1);
        }
      ")),
    ),
    page_navbar(id = "tabs",
      theme = my_theme,
      title = tagList(
        img(src = "bes-E.png", height = "30px", class = "me-2 img-invert",
            style = "vertical-align: middle;"),
        span("BES Hackathon", style = "vertical-align: middle;")
      ),
      fillable_mobile = TRUE,
      nav_panel("About",
                strong("BES Open Science Hackathon"),
                p("On 29th and 30th September 2025, the British Ecological Society (BES) organised a hackathon, with the goal of collecting data on the availability of data and code for papers published in BES journals. The hackathon included in-person participation at BES Headquarters and Natural History Museum, London, and remote participation via a Discord server."),
                strong("Manuscript"),
                p("A manuscript reporting on the findings of the hackathon is now available on EcoEvoRxiv."),
                p(HTML("Cooper et al., 2025. Data- and code-archiving in the British Ecological Society journals: present status and recommendations for future improvements. EcoEvoRxiv. <a href='https://doi.org/10.32942/X26W9V' target='_blank'>https://doi.org/10.32942/X26W9V</a>")),
                strong("Contributors"),
                p("Contributors to the hackathon, and coauthors of the manuscript, are listed below:"),
                p("N. Cooper (corresponding author); B.J. Allen; N. Almaani; R. Altwegg; J. Balogh; H. Balti; R.A. Barber; M.E. Barbosa de Sousa; J.G.N.  Barreat; C.F. Barrett; R. Bates; A.M.J.M. Beale; L. Bliard; N. Blömer; D. Borovyk; C. Bunnenberg; E.A. Bygate; L. Cash; N. Chatterjee; T.-W. Chen; A. Chiti; S.S.-W. Chung; H. Chuquillanqui; A. Ciezarek; A. Clarkson; E. Codling; A. Corradini; A. Cowans; S. Dartnell; A.J.S. Davis; L.L.M. De Benedictis; G.G. Deme; C. Devenish; S. Dimri; C. Dittrich; K.R. Dorheim; H.B. Drage; M.-A. Dueñas; A. Efstathiou; L.C. Evans; M.E. Ferreira Santos; A.J. Foxx; R.J. Gardiner; J. Gaudard; W. Gearty; L. Graham; V.M. Graves; H.M. Green; R.V. Greensmith; S. Gérard; A.H. Halbritter; T.R. Hartke; R.M. Hechler; B.J. Hindle; P.-Y. Hsing; S. Illanas; G. Iossa; E.E. Jackson; L.A. Jones; F.A.M. Jones; J.A. Jones; J.F. Jupke; N.N. Kaunain; R. Kennedy; M.R. Kerr; N.J. Kester;  M.  Klaassen;  O.  Konecka;  R.  Krasnow;  R.  Kukowski;  A.  Kumar;  R.  Kuminski;  K.S. Kuzey; L. Laccetti; M. Lagisz; H. Latifi; N. Lecomte; K.D. Luchmun; A. Lévêque; A. Markitantova; B.M. Marshall; E. Menares-Barraza; D. Mertens; G. Mesbahi; J. Meyer; J. Millard; L.M. Montilla; B. Moreira; A. Morera; G. Murali; M.P. Murray; F. Märker; K. Nagahawatte; C.L. Narraway; H.I. Niven; A.G. Nytko; B. Ohse; S. Patterson; H.R.P. Phillips; R. Pienaar; P. Pollo; A. Ponce; L.M.V. Porto; E.F.R. Preston; C.S. Prieul; A. Prylutska; O. Prylutskyi; K. Radman-Daw; A.M. Raharison; R. Rao; F.R. Read; S. Record; W. Rees; R. Reeve; H. Rhodes; C. Rocabado; A. Rouviere; A. Rönnfeldt; A. Sagouis; S.P. Sakhalkar; G.S. Santos; M.A. Shakur; R. Shaw; D. Siegieda; L. Šmídova; B.I. Simmons; H.G. Sisley; A. Sánchez-Tójar; F.G. Taboada; N.G. Taylor; H. Teague; K. Thrikkadeeri; V. Thuroczy; A. Varah; K.L. Vinay; C.M. Watrobska; Z.B. Williams; S.M. Windecker"),
                img(src="bes-logo.svg", align = "left", class = "img-invert",
                    style="max-width: 350px;"),
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
                                  Violin = "geom_violin",
                                  Point = "geom_point")
                    ),
                    selectInput(
                      inputId = 'x', 
                      label = 'X-axis variable', 
                      choices = c(None='.', colnames(dat_plot))
                    ), 
                    selectInput(
                      inputId = 'y', 
                      label = 'Y-axis variable', 
                      choices = c(None='.', colnames(dat_plot))
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
                          choices = c(None='.', colnames(dat_plot))
                        ),
                        hidden(checkboxInput(
                          inputId = "exclude_na_colour",
                          label = "Exclude NA from colour",
                          value = FALSE
                        )),
                        selectInput(
                          inputId = 'fill', 
                          label = 'Fill by', 
                          choices = c(None='.', colnames(dat_plot))
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
                          choices = c(None='.', colnames(dat_plot))
                        ),
                        selectInput(
                          inputId = 'facet_col', 
                          label = 'Facet column by',
                          choices = c(None='.', colnames(dat_plot))
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
