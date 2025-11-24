# GLOBAL
# UI --------------------------------------------------------------------
# Load required libraries
library(shiny)
library(bslib)
## Theme
my_theme <- bs_theme(version = 5, preset = "bootstrap")

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
dat <- readRDS("app/data/dat.RDS")