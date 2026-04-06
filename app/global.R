# GLOBAL
# UI --------------------------------------------------------------------
# Load required libraries
library(shiny)
library(bslib)
library(shinyjs)

# Save URL components for bookmarking with shinylive
jscode <- "
shinyjs.init = function() {
  $('#url_search').val(window.parent.location.search);
  $('#url_origin').val(window.parent.location.origin + window.parent.location.pathname);
}"

## Theme
my_theme <- bs_theme(version = 5, preset = "bootstrap", secondary = "#cfe9b4")

# Server ----------------------------------------------------------------
# Load required libraries
# Data tables
library(DT)
# Required to make ggplot work(?)
library(munsell)
# General plotting
library(ggplot2)

# Data ------------------------------------------------------------------
# Download required data
# dat <- read.csv("https://github.com/nhcooper123/reproduce-reuse-recycle/raw/refs/heads/main/data/BES-data-code-hackathon-cleaned_2025-11-16.csv")
# saveRDS(object = dat, file = "app/data/dat.RDS")
# Read data
dat <- readRDS("data/dat.RDS")
# Drop and relocate columns
dat <- dat[, c("doi", "journal", "article_type", "year_published", "country_first",
               "data_used", "data_availability", "data_link", "data_archive",
               "data_doi", "data_license", "data_license_type", "data_download",
               "data_open", "data_format", "data_README", "data_completeness", 
               "code_used", "code_archived", "code_availability", "code_link", 
               "code_archive", "code_doi", "code_license", "code_license_type",
               "code_CITATION", "code_download", "code_open", "code_format", 
               "code_language", "code_README")]
colnames(dat) <- tolower(gsub(pattern = "_", replacement = " ", x = colnames(dat)))
