library(shinylive)

template_params <- list(
  title = "BES Data & Code Archiving",
  include_in_head = paste0('<link rel="icon" type="image/png" href="/shiny-bes-hackathon/favicon-96x96.png" sizes="96x96" />\n',
                           '    <link rel="icon" type="image/svg+xml" href="/shiny-bes-hackathon/favicon.svg" />\n',
                           '    <link rel="shortcut icon" href="/shiny-bes-hackathon/favicon.ico" />\n',
                           '    <link rel="apple-touch-icon" sizes="180x180" href="/shiny-bes-hackathon/apple-touch-icon.png" />\n',
                           '    <link rel="manifest" href="/shiny-bes-hackathon/site.webmanifest" />\n')
)

shinylive::export("app", "site", assets_version = "0.10.6",
                  template_params = template_params)