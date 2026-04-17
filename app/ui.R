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
      tags$title("BES Data & Code Archiving"),
      tags$link(rel = "shortcut icon",
                href = "/favicon/favicon.ico"),
      tags$link(rel = "icon", type = "image/png",
                href = "/favicon/favicon-96x96.png", sizes = "96x96"),
      tags$link(rel = "icon", type = "image/svg+xml",
                href = "/favicon/favicon.svg"),
      tags$link(rel = "apple-touch-icon", sizes = "180x180",
                href = "/favicon/apple-touch-icon.png"),
      tags$link(rel = "manifest",
                href = "/favicon/site.webmanifest"),
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
          var $footer = $('.site-footer');
          var footerHeight = $footer.length ? $footer.outerHeight(true) : 0;
          var padding = 10;
          var newHeight = wh - topOffset - bottomChrome - footerHeight - padding;
          $scrollBody.css('max-height', newHeight + 'px');
          if (settings.oScroller) {
            settings.oScroller.dom.scroller.style.height = newHeight + 'px';
            settings.oScroller.measure();
          }
        }
      
        var dtSettings = null;
        $(document).on('init.dt', function(e, settings) {
          dtSettings = settings;
          adjustDTHeight(settings);
          $(window).on('resize', function() {
            adjustDTHeight(settings);
          });
        });
        
        $(document).on('shown.bs.tab', function() {
          if (dtSettings) {
            setTimeout(function() {
              adjustDTHeight(dtSettings);
              setTimeout(function() {
                adjustDTHeight(dtSettings);
              }, 200);
            }, 50);
          }
        });
        
        function adjustTabPaneHeight() {
          var navbarHeight = $('.navbar').outerHeight(true) || 0;
          var footerHeight = $('.site-footer').outerHeight(true) || 0;
          $('.tab-pane').css({
            'overflow-y': 'auto',
            'max-height': 'calc(100vh - ' + (navbarHeight + footerHeight) + 'px)'
          });
        }
        
        $(document).on('shiny:connected', adjustTabPaneHeight);
        $(window).on('resize', adjustTabPaneHeight);
      ")),
      tags$style(HTML("
        [data-bs-theme='dark'] .img-invert {
          filter: invert(1);
        }
        .site-footer {
          position: fixed;
          width: 100%;
          bottom: 0;
          padding-top: 10px;
          padding-bottom: 10px;
          padding-left: 40px;
          padding-right: 40px;
          z-index: 1000;
        }
        .shiny-plot-output {
          position: relative;
        }
        .shiny-plot-output.recalculating::after {
          content: '';
          position: absolute;
          top: 50%;
          left: 50%;
          width: 40px;
          height: 40px;
          margin: -20px 0 0 -20px;
          border: 4px solid #ccc;
          border-top-color: #333;
          border-radius: 50%;
          animation: spin 0.8s linear infinite;
        }
        .shiny-plot-output.recalculating {
          opacity: 0.5;
        }
        @keyframes spin {
          to { transform: rotate(360deg); }
        }
        .about-layout {
          display: flex;
          gap: 16px;
          align-items: flex-start;
        }
        .about-text {
          padding-top: 10px;
          padding-bottom: 10px;
          padding-left: 25px;
          padding-right: 25px;
          line-height: 1.7em;
          flex: 1.2;
          min-width: 0;
        }
        .about-sidebar {
          flex: 0.8;
          min-width: 0;
        }
        .about-sidebar img {
          padding-top: 10px;
          padding-bottom: 10px;
          padding-left: 25px;
          padding-right: 25px;
          max-width: 100%;
          height: auto;
        }
        @media (max-width: 768px) {
          .about-layout {
            flex-direction: column;
          }
        }
        @media (max-width: 768px) {
          .navbar-collapse {
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background-color: var(--bslib-navbar-light-bg);
            z-index: 1050;
            padding: 1rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
          }
          [data-bs-theme='dark'] .navbar-collapse {
            background-color: var(--bslib-navbar-dark-bg);
          }
        }
      ")),
    ),
    page_navbar(id = "tabs",
      theme = my_theme,
      title = tagList(
        img(src = "bes-E.png", height = "30px", class = "me-2 img-invert",
            style = "vertical-align: middle;",
            onclick = "Shiny.setInputValue('tabs', 'About'); return false;"),
        tags$a("Data & Code Archiving",
               style = "vertical-align: middle; color: black; text-decoration: none;",
               href = "#",
               onclick = "Shiny.setInputValue('tabs', 'About'); return false;")
      ),
      fillable_mobile = TRUE,
      nav_panel("About",
                tags$div(
                  class = "about-layout",
                  tags$div(
                    class = "about-text",
                    h3("Data- and code-archiving in the British Ecological Society journals: present status and recommendations for future improvements"),
                    p("On the 29th and 30th of September 2025, the British Ecological Society (BES) organised a hackathon, with the goal of collecting data on the availability of data and code for papers published in their respective journals (Ecological Solutions and Evidence, Functional Ecology, Journal of Animal Ecology, Journal of Applied Ecology, Journal of Ecology, Methods in Ecology and Evolution, and People and Nature). The hackathon included in-person participation at BES Headquarters and Natural History Museum, London, and remote participation via a Discord server."),
                    p("This Shiny Application is a companion to the manuscript reporting the findings of the hackathon (Cooper et al., 2025), enabling users to explore the data collected during the hackathon. The raw data can be visualised through the 'Plot' tab, and individual records inspected through the 'Table' tab. If preferred, the raw data can also be downloaded via the button below."),
                    tags$a(
                      "READ THE REPORT",
                      href = "https://doi.org/10.32942/X26W9V",
                      target = "_blank",
                      class = "btn btn-default",
                      style = "font-weight: bold; border-color: black;",
                      download = NA
                    ),
                    tags$a(
                      "DOWNLOAD THE DATA",
                      href = "https://anonymous.4open.science/r/reproduce-reuse-recycle-71FD",
                      target = "_blank",
                      class = "btn btn-default",
                      style = "font-weight: bold; border-color: black;",
                      download = NA
                    ),
                    br(),
                    br(),
                    h4("Contributors"),
                    p("A number of individuals contributed to the hackathon and the development of the report. A full list of these contributors is included below:"),
                    p("N. Cooper (corresponding author); B.J. Allen; N. Almaani; R. Altwegg; J. Balogh; H. Balti; R.A. Barber; M.E. Barbosa de Sousa; J.G.N.  Barreat; C.F. Barrett; R. Bates; A.M.J.M. Beale; L. Bliard; N. Blömer; D. Borovyk; C. Bunnenberg; E.A. Bygate; L. Cash; N. Chatterjee; T.-W. Chen; A. Chiti; S.S.-W. Chung; H. Chuquillanqui; A. Ciezarek; A. Clarkson; E. Codling; A. Corradini; A. Cowans; S. Dartnell; A.J.S. Davis; L.L.M. De Benedictis; G.G. Deme; C. Devenish; S. Dimri; C. Dittrich; K.R. Dorheim; H.B. Drage; M.-A. Dueñas; A. Efstathiou; L.C. Evans; M.E. Ferreira Santos; A.J. Foxx; R.J. Gardiner; J. Gaudard; W. Gearty; L. Graham; V.M. Graves; H.M. Green; R.V. Greensmith; S. Gérard; A.H. Halbritter; T.R. Hartke; R.M. Hechler; B.J. Hindle; P.-Y. Hsing; S. Illanas; G. Iossa; E.E. Jackson; L.A. Jones; F.A.M. Jones; J.A. Jones; J.F. Jupke; N.N. Kaunain; R. Kennedy; M.R. Kerr; N.J. Kester;  M.  Klaassen;  O.  Konecka;  R.  Krasnow;  R.  Kukowski;  A.  Kumar;  R.  Kuminski;  K.S. Kuzey; L. Laccetti; M. Lagisz; H. Latifi; N. Lecomte; K.D. Luchmun; A. Lévêque; A. Markitantova; B.M. Marshall; E. Menares-Barraza; D. Mertens; G. Mesbahi; J. Meyer; J. Millard; L.M. Montilla; B. Moreira; A. Morera; G. Murali; M.P. Murray; F. Märker; K. Nagahawatte; C.L. Narraway; H.I. Niven; A.G. Nytko; B. Ohse; S. Patterson; H.R.P. Phillips; R. Pienaar; P. Pollo; A. Ponce; L.M.V. Porto; E.F.R. Preston; C.S. Prieul; A. Prylutska; O. Prylutskyi; K. Radman-Daw; A.M. Raharison; R. Rao; F.R. Read; S. Record; W. Rees; R. Reeve; H. Rhodes; C. Rocabado; A. Rouviere; A. Rönnfeldt; A. Sagouis; S.P. Sakhalkar; G.S. Santos; M.A. Shakur; R. Shaw; D. Siegieda; L. Šmídova; B.I. Simmons; H.G. Sisley; A. Sánchez-Tójar; F.G. Taboada; N.G. Taylor; H. Teague; K. Thrikkadeeri; V. Thuroczy; A. Varah; K.L. Vinay; C.M. Watrobska; Z.B. Williams; S.M. Windecker.")
                  ),
                  tags$div(
                    class = "about-sidebar",
                    tags$figure(
                      tags$img(src = "example-plot.png", alt = "Description of image", align = "left", style="width: 100%"),
                      tags$figcaption(style = "color: #777; font-style: italic;",
                                      "Code availability for articles published within British Ecological Society journals.",
                                      tags$a("Want to interact with this figure?",
                                             href = "#",
                                             onclick = "Shiny.setInputValue('tabs', 'Plot'); return false;"))
                      ),
                    img(src = "bes-logo.svg", class = "img-invert",
                        style="max-width: 100%; height: auto; padding-left: 20%; padding-right: 20%",
                        onclick = "window.open('https://www.britishecologicalsociety.org', '_blank')")
                  )
                ),
      ),
      nav_panel("Plot", 
                layout_sidebar(
                  sidebar = sidebar(
                    selectInput(
                      inputId = 'geom', 
                      label = 'Plot type', 
                      choices = c(bar = "geom_bar",
                                  boxplot = "geom_boxplot",
                                  violin = "geom_violin",
                                  point = "geom_point"),
                      selected = "geom_bar"
                    ),
                    selectInput(
                      inputId = 'x', 
                      label = 'X-axis variable', 
                      choices = c(None='.', colnames(dat_plot)),
                      selected = "journal"
                    ),
                    hidden(checkboxInput(
                      inputId = "x_split_vals",
                      label = "Split semi-colon-separated values for x variable",
                      value = FALSE
                    )),
                    selectInput(
                      inputId = 'y', 
                      label = 'Y-axis variable', 
                      choices = c(None='.', colnames(dat_plot))
                    ),
                    hidden(checkboxInput(
                      inputId = "y_split_vals",
                      label = "Split semi-colon-separated values for y variable",
                      value = FALSE
                    )),
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
                          choices = c(None='.', colnames(dat_plot)),
                          selected = "code availability"
                        ),
                        hidden(checkboxInput(
                          inputId = "exclude_na_fill",
                          label = "Exclude NA from fill",
                          value = TRUE
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
                            paste("Add filters to subset to specific rows of",
                                  "data. You can add multiple filters and they",
                                  "will be combined with AND logic.")
                          )
                        ),
                        value = "filters",
                        div(id = "filter_container"),
                        actionButton("add_filter", "Add filter", 
                                     icon = icon("plus"))
                      ),
                      accordion_panel(
                        span(
                          "Exclusions ",
                          tooltip(
                            icon("info-circle"),
                            paste("Add exclusions to discard specific rows of",
                                  "data. You can add multiple exclusions and",
                                  "they will be combined with OR logic.")
                          )
                        ),
                        value = "excludes",
                        div(id = "exclude_container"),
                        actionButton("add_exclude", "Add exclusion", 
                                     icon = icon("plus"))
                      ),
                    ),
                    checkboxInput(
                      inputId = 'jitter', 
                      label = 'Jitter', 
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
    ),
    tags$footer(
      class = "site-footer mt-auto py-3 bg-light",
      tags$div(
        tags$span("Cooper et al. (2026). Data-and code-archiving in the British Ecological Society journals: present status and recommendations for future improvements."),
        tags$em("EcoEvoRxiv."),
        tags$a("https://doi.org/10.32942/X26W9V", href = "https://doi.org/10.32942/X26W9V"),
        tags$br(),
        tags$span("Shiny App created by Lewis A. Jones, William Gearty, and Bethany J. Allen.")
      )
    )
  )
}
