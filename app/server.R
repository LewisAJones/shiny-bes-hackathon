# SERVER
server <- function(input, output, session) {
  
  # Data ------------------------------------------------------------------
  dataset <- reactive({
    tmp <- dat
    tmp$doi <- paste0('<a href=\"https://doi.org/', tmp$doi,'" target="_blank">', tmp$doi ,"</a>")
    tmp
  })
  
  # Plot ------------------------------------------------------------------
  output$plot <- renderPlot({
    dat <- dataset()
    # Apply dynamic filters
    for (id in filter_ids()) {
      col <- input[[paste0(id, "_col")]]
      vals <- input[[paste0(id, "_vals")]]
      if (!is.null(col) && col != "" && !is.null(vals)) {
        dat <- dat[dat[[col]] %in% vals, ]
      }
    }
    if (input$exclude_na_colour != FALSE && input$colour != '.') {
      dat <- dat[!is.na(dat[[input$colour]]), ]
    }
    if (input$exclude_na_fill != FALSE && input$fill != '.') {
      dat <- dat[!is.na(dat[[input$fill]]), ]
    }
    p <- ggplot(data = dat) +
      scale_colour_viridis_d() +
      scale_fill_viridis_d(na.value = "grey50") +
      theme_bw()
    
    if (input$x != '.') p <- p + aes(x = .data[[input$x]])
    
    if (input$y != '.') p <- p + aes(y = .data[[input$y]])
    
    if (input$colour != '.') p <- p + aes(colour = .data[[input$colour]])
    
    if (input$fill != '.') p <- p + aes(fill = .data[[input$fill]])
    
    if (input$geom != '.') p <- p + get(input$geom)()
    
    facets <- paste(input$facet_row, '~', input$facet_col)
    
    if (facets != '. ~ .') p <- p + facet_grid(facets)
    
    if (input$jitter) p <- p + geom_jitter()
    if (input$smooth) p <- p + geom_smooth()
    
    # Valid ggplot build?
    error_msg <- tryCatch({
      ggplot_build(p)
      NULL
    }, error = function(e) {
      e$message
    })
    
    validate(
      need(is.null(error_msg), paste0(
      "The selected combination of settings is not valid for plotting. ",
      "Please select alternative settings. \n", 
      "The specific plot error is as follows: \n > ", 
      error_msg))
    )
    
    p
  })
  
  # Table -----------------------------------------------------------------
  output$table <- renderDT(
    dataset(),
    extensions = c("Scroller", "KeyTable"),
    rownames = FALSE,
    options = list(
      deferRender = TRUE,
      scrollY = 710,
      scrollX = TRUE,
      scroller = TRUE,
      keys = TRUE
    ),
    filter = list(
      position = 'top'
    ),
    escape = FALSE,
    selection = 'none'
  )
  
  observeEvent(input$url_search, {
    query <- parseQueryString(input$url_search)
    
    # Select tab if specified
    if (!is.null(query$tabs)) {
      nav_select("tabs", selected = query$tabs, session)
    }
    
    # Send remaining params to client
    query$tabs <- NULL
    if (length(query) > 0) {
      session$sendCustomMessage("updateInputs", query)
    }
  }, priority = 1)
  
  # Handlers -----------------------------------------------------
  # Handle bookmark button
  observeEvent(input$._bookmark_, {
    # modified from the shiny package
    exclude <- c("._bookmark_", "url_search", "url_origin",
                 "table_state", "table_search_columns")
    input_vals <- shiny:::serializeReactiveValues(input, exclude = exclude)
    # remove remaining DT-associated inputs
    input_vals <- input_vals[!grepl("^table_", names(input_vals))]
    # remove an inputs that are still their default values
    input_vals <- unlist(Filter(\(x) !(x == "." || isFALSE(x)), input_vals))
    res <- ""
    # If any input values are present, add them.
    if (length(input_vals) != 0) {
      res <- paste0(res, "?",
                    paste0(
                      httpuv::encodeURIComponent(names(input_vals)),
                      "=",
                      httpuv::encodeURIComponent(input_vals),
                      collapse = "&"
                    )
      )
    }
    showModal(urlModal(paste0(input$url_origin, res),
                       subtitle = "This link stores the current state of this
                                   application."))
  })
  
  # Show exclude NA from colour option if colour variable selected
  observe({
    if (input$colour != '.') {
      show("exclude_na_colour")
    } else {
      hide("exclude_na_colour")
    }
  })
  # Show exclude NA from fill option if fill variable selected
  observe({
    if (input$fill != '.') {
      show("exclude_na_fill")
    } else {
      hide("exclude_na_fill")
    }
  })
  
  # Filters ---------------------------------------------------------------
  filter_ids <- reactiveVal(character(0))
  filter_counter <- reactiveVal(0)
  
  observeEvent(input$add_filter, {
    n <- filter_counter() + 1
    filter_counter(n)
    id <- paste0("filter_", n)
    filter_ids(c(filter_ids(), id))
    
    insertUI(
      selector = "#filter_container",
      where = "beforeEnd",
      ui = div(
        id = id,
        class = "mb-3 p-2 border rounded",
        div(
          class = "d-flex justify-content-between align-items-center mb-1",
          tags$strong(paste("Filter", n)),
          actionButton(
            inputId = paste0(id, "_remove"),
            label = NULL,
            icon = icon("xmark"),
            class = "btn-sm btn-outline-danger"
          )
        ),
        selectInput(
          inputId = paste0(id, "_col"),
          label = "Column",
          choices = c("Select..." = "", colnames(dat))
        ),
        uiOutput(paste0(id, "_values_ui"))
      )
    )
    
    # Render value picker based on selected column
    output[[paste0(id, "_values_ui")]] <- renderUI({
      col <- input[[paste0(id, "_col")]]
      req(col, col != "")
      vals <- sort(unique(dat[[col]]))
      vals <- vals[!is.na(vals)]
      selectInput(
        inputId = paste0(id, "_vals"),
        label = "Values",
        choices = vals,
        multiple = TRUE
      )
    })
    
    # Remove handler
    observeEvent(input[[paste0(id, "_remove")]], {
      removeUI(selector = paste0("#", id))
      filter_ids(setdiff(filter_ids(), id))
    }, once = TRUE)
  })
  
}
