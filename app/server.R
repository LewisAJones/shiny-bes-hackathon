# SERVER
server <- function(input, output, session) {
  
  # Data ------------------------------------------------------------------
  dat_plot_filt <- reactive({
    tmp <- dat_plot
    # split values if requested
    if (input$x_split_vals) {
      split_vals <- strsplit(tmp[[input$x]], ";")
      tmp <- tmp[rep(seq_len(nrow(tmp)), lengths(split_vals)), ]
      tmp[[input$x]] <- unlist(split_vals)
    }
    if (input$y_split_vals) {
      split_vals <- strsplit(tmp[[input$y]], ";")
      tmp <- tmp[rep(seq_len(nrow(tmp)), lengths(split_vals)), ]
      tmp[[input$y]] <- unlist(split_vals)
    }
    
    # Apply dynamic filters
    for (id in filter_ids()) {
      col <- input[[paste0(id, "_col")]]
      vals <- input[[paste0(id, "_vals")]]
      if (!is.null(col) && col != "" && !is.null(vals)) {
        tmp <- tmp[tmp[[col]] %in% vals, ]
      }
    }
    # Apply dynamic exclusions
    for (id in exclude_ids()) {
      col <- input[[paste0(id, "_col")]]
      vals <- input[[paste0(id, "_vals")]]
      if (!is.null(col) && col != "" && !is.null(vals)) {
        tmp <- tmp[!(tmp[[col]] %in% vals), ]
      }
    }
    # Apply NA exclusions
    if (input$exclude_na_colour != FALSE && input$colour != '.') {
      tmp <- tmp[!is.na(tmp[[input$colour]]), ]
    }
    if (input$exclude_na_fill != FALSE && input$fill != '.') {
      tmp <- tmp[!is.na(tmp[[input$fill]]), ]
    }
    tmp
  })
  
  # Plot ------------------------------------------------------------------
  output$plot <- renderPlot({
    y_label <- if (input$geom == 'geom_bar') {
      "Count"
    } else if (input$y != '.') {
      str_to_title(input$y)
    } else {
      NULL
    }
    p <- ggplot(data = dat_plot_filt()) +
      labs(x = if (input$x != '.') str_to_title(input$x) else NULL,
           y = y_label,
           colour = if (input$colour != '.') str_to_title(input$colour) else NULL,
           fill = if (input$fill != '.') str_to_title(input$fill) else NULL) +
      theme_bw(paper = "#f8f3ef", ink = "#212121", base_size = 20) +
      theme(legend.position = "bottom")
    
    journal_colours <- c(
      "Ecological Solutions and Evidence" = "#A2DACC", 
      "Functional Ecology" = "#EDC04E",
      "Journal of Animal Ecology" = "#AC92ED",
      "Journal of Applied Ecology" = "#45B599",
      "Journal of Ecology" = "#AECEF6",
      "Methods in Ecology and Evolution" = "#e3626f",
      "People and Nature" = "#DDAC93"
    )
    if (input$colour == "journal") {
      p <- p + scale_colour_manual(values = journal_colours)
    } else {
      p <- p + scale_colour_viridis_d(end = 0.8, na.value = "grey50")
    }
    
    if (input$fill == "journal") {
      p <- p + scale_fill_manual(values = journal_colours)
    } else {
      p <- p + scale_fill_viridis_d(end = 0.8, na.value = "grey50")
    }
    
    if (input$x != '.') p <- p + 
      aes(x = if (is.numeric(.data[[input$x]])) .data[[input$x]] else str_wrap(.data[[input$x]], width = 10))
    
    if (input$y != '.') p <- p + 
      aes(y = if (is.numeric(.data[[input$y]])) .data[[input$y]] else str_wrap(.data[[input$y]], width = 10))
    
    if (input$colour != '.') p <- p + aes(colour = .data[[input$colour]])
    
    if (input$fill != '.') p <- p + aes(fill = .data[[input$fill]])
    
    p <- p + get(input$geom)()
    
    # Handle x-axis labels
    if (input$x %in% c("country first", "data format")) {
      p <- p + aes(x = str_wrap(.data[[input$x]], width = 70))
      p <- p + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
    }
    
    facets <- paste0("`", input$facet_row, "`", '~', "`", input$facet_col, "`")
    
    if (facets != '.~.') p <- p + facet_grid(facets)
    
    if (input$jitter) p <- p + geom_jitter()
    
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
    dat,
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
  
  # Handlers -----------------------------------------------------
  ## Bookmark button --------------------------------------
  observeEvent(input$._bookmark_, {
    # modified from the shiny package
    exclude <- c("._bookmark_", "url_search", "url_origin", "url_hash",
                 "table_state", "table_search_columns",
                 "add_filter", "add_exclude", "plot_accordion")
    input_vals <- shiny:::serializeReactiveValues(input, exclude = exclude)
    # remove DT- and filter-associated inputs
    input_vals <- input_vals[!grepl("^(table_|filter_\\d|exclude_\\d)",
                                    names(input_vals))]
    
    # remove any inputs that are still their default values
    input_vals <- unlist(Filter(\(x) !(x == "." || isFALSE(x)), input_vals))
    
    # Serialize active filters as JSON
    filters <- list()
    for (id in filter_ids()) {
      col <- input[[paste0(id, "_col")]]
      vals <- input[[paste0(id, "_vals")]]
      if (!is.null(col) && col != "") {
        filters[[length(filters) + 1]] <- list(col = col, vals = vals)
      }
    }
    
    # Serialize active excludes as JSON
    excludes <- list()
    for (id in exclude_ids()) {
      col <- input[[paste0(id, "_col")]]
      vals <- input[[paste0(id, "_vals")]]
      if (!is.null(col) && col != "") {
        excludes[[length(excludes) + 1]] <- list(col = col, vals = vals)
      }
    }
    
    res <- ""
    # If any input values are present, add them
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
    
    # If any filter values are present, add them
    if (length(filters) > 0) {
      sep <- if (nchar(res) > 0) "&" else "?"
      res <- paste0(res, sep, "filters=",
                    httpuv::encodeURIComponent(
                      jsonlite::toJSON(filters, auto_unbox = TRUE)))
    }
    
    # If any exclusion values are present, add them
    if (length(excludes) > 0) {
      sep <- if (nchar(res) > 0) "&" else "?"
      res <- paste0(res, sep, "excludes=",
                    httpuv::encodeURIComponent(
                      jsonlite::toJSON(excludes, auto_unbox = TRUE)))
    }
    
    showModal(urlModal(paste0(input$url_origin, res),
                       subtitle = "This link stores the current state of this
                                   application."))
  })
  
  ## Parse bookmarking ------------------------------------------------------
  observeEvent(input$url_search, {
    query <- parseQueryString(input$url_search)
    
    # Select tab if specified
    if (!is.null(query$tabs)) {
      nav_select("tabs", selected = query$tabs, session)
    }
    
    # Restore filters
    if (!is.null(query$filters)) {
      filters <- jsonlite::fromJSON(query$filters, simplifyVector = FALSE)
      pending_filters(filters)
      
      # Open the accordion so selectize inputs initialize
      accordion_panel_open("plot_accordion", "filters")
      
      for (i in seq_along(filters)) {
        create_filter()
      }
      
      session$onFlushed(function() {
        for (i in seq_along(filters)) {
          updateSelectInput(session, paste0("filter_", i, "_col"),
                            selected = filters[[i]]$col)
        }
        # Close after values are set
        shinyjs::delay(500, {
          accordion_panel_close("plot_accordion", "filters")
        })
      })
    }
    
    # Restore filters and exclusions
    has_filters <- !is.null(query$filters)
    has_excludes <- !is.null(query$excludes)
    
    if (has_filters || has_excludes) {
      # Open all needed panels at once
      panels_to_open <- c(
        if (has_filters) "filters",
        if (has_excludes) "excludes"
      )
      accordion_panel_open("plot_accordion", panels_to_open)
    }
    
    if (has_filters) {
      filters <- jsonlite::fromJSON(query$filters, simplifyVector = FALSE)
      pending_filters(filters)
      for (i in seq_along(filters)) {
        create_filter()
      }
    }
    
    if (has_excludes) {
      excludes <- jsonlite::fromJSON(query$excludes, simplifyVector = FALSE)
      pending_excludes(excludes)
      for (i in seq_along(excludes)) {
        create_exclude()
      }
    }
    
    if (has_filters || has_excludes) {
      session$onFlushed(function() {
        # Set all columns in one flush
        if (has_filters) {
          for (i in seq_along(filters)) {
            updateSelectInput(session, paste0("filter_", i, "_col"),
                              selected = filters[[i]]$col)
          }
        }
        if (has_excludes) {
          for (i in seq_along(excludes)) {
            updateSelectInput(session, paste0("exclude_", i, "_col"),
                              selected = excludes[[i]]$col)
          }
        }
        # Close panels after values are set
        shinyjs::delay(500, {
          accordion_panel_close("plot_accordion", panels_to_open)
        })
      })
    }
    
    # Restore other params
    query$tabs <- NULL
    query$filters <- NULL
    query$excludes <- NULL
    if (length(query) > 0) {
      session$sendCustomMessage("updateInputs", query)
    }
  }, priority = 1)
  
  ## Show/hide options ------------------------------------------------------
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
  
  # Hide y-axis variable when selecting geom_bar
  observe({
    if (input$geom != 'geom_bar') {
      show("y")
    } else {
      hide("y")
      updateSelectInput(session, "y", selected = ".")
    }
  })
  
  # show split values options if selected variable was a multiselect
  observe({
    if (input$x %in% multi_select) {
      show("x_split_vals")
    } else {
      hide("x_split_vals")
      updateCheckboxInput(session, "x_split_vals", value = FALSE)
    }
    if (input$y %in% multi_select) {
      show("y_split_vals")
    } else {
      hide("y_split_vals")
      updateCheckboxInput(session, "y_split_vals", value = FALSE)
    }
  })
  
  ## Filters ---------------------------------------------------------------
  filter_ids <- reactiveVal(character(0))
  filter_counter <- reactiveVal(0)
  pending_filters <- reactiveVal(list())
  
  create_filter <- function() {
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
      
      # Check for pending restore values
      pf <- pending_filters()
      filter_num <- as.integer(sub("filter_", "", id))
      selected_vals <- NULL
      if (filter_num <= length(pf) && !is.null(pf[[filter_num]]$vals)) {
        selected_vals <- unlist(pf[[filter_num]]$vals)
      }
      
      selectInput(
        inputId = paste0(id, "_vals"),
        label = "Values",
        choices = vals,
        selected = selected_vals,
        multiple = TRUE
      )
    })
    
    # Remove handler
    observeEvent(input[[paste0(id, "_remove")]], {
      removeUI(selector = paste0("#", id))
      filter_ids(setdiff(filter_ids(), id))
    }, once = TRUE)
  }
  
  # Handle add filter button
  observeEvent(input$add_filter, {
    create_filter()
  })
  
  ## Exclusions ---------------------------------------------------------------
  exclude_ids <- reactiveVal(character(0))
  exclude_counter <- reactiveVal(0)
  pending_excludes <- reactiveVal(list())
  
  create_exclude <- function() {
    n <- exclude_counter() + 1
    exclude_counter(n)
    id <- paste0("exclude_", n)
    exclude_ids(c(exclude_ids(), id))
    
    insertUI(
      selector = "#exclude_container",
      where = "beforeEnd",
      ui = div(
        id = id,
        class = "mb-3 p-2 border rounded",
        div(
          class = "d-flex justify-content-between align-items-center mb-1",
          tags$strong(paste("Exclusion", n)),
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
      
      # Check for pending restore values
      pe <- pending_excludes()
      exclude_num <- as.integer(sub("exclude_", "", id))
      selected_vals <- NULL
      if (exclude_num <= length(pe) && !is.null(pe[[exclude_num]]$vals)) {
        selected_vals <- unlist(pe[[exclude_num]]$vals)
      }
      
      selectInput(
        inputId = paste0(id, "_vals"),
        label = "Values",
        choices = vals,
        selected = selected_vals,
        multiple = TRUE
      )
    })
    
    # Remove handler
    observeEvent(input[[paste0(id, "_remove")]], {
      removeUI(selector = paste0("#", id))
      exclude_ids(setdiff(exclude_ids(), id))
    }, once = TRUE)
  }
  
  # Handle add filter button
  observeEvent(input$add_exclude, {
    create_exclude()
  })
  
  ## Back/forward browser actions ----------------------------------
  observeEvent(input$url_hash, {
    currentHash <- sub("#", "", input$url_hash)
    if (is.null(input$tabs) || !is.null(currentHash) && currentHash != input$tabs) {
      freezeReactiveValue(input, "tabs")
      nav_select("tabs", selected = currentHash, session)
    }
  }, priority = 1)
  
  ## push changes to the sub-URL to the browser history so that back/forward browser buttons work
  observeEvent(input$tabs, {
    currentHash <- sub("#", "", input$url_hash)
    pushQueryString <- paste0("#", input$tabs)
    if (is.null(currentHash) || currentHash != input$tabs) {
      freezeReactiveValue(input, "tabs")
      runjs(paste0("window.parent.history.pushState(null, null, '", pushQueryString, "')"))
      updateTextInput(session, "url_hash", value = pushQueryString)
    }
  }, priority = 0)
  
}
