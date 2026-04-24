# Replace vctrs with version compatible with bundled rlang 1.1.6
# See: https://github.com/posit-dev/shinylive/issues/221
vctrs_dir <- "site/shinylive/webr/packages/vctrs"

# Remove the incompatible version
old_files <- list.files(vctrs_dir, pattern = "\\.tgz$", full.names = TRUE)
file.remove(old_files)

# Copy in the compatible version
file.copy("app/wasm-overrides/vctrs_0.6.5.tgz",
          file.path(vctrs_dir, "vctrs_0.6.5.tgz"))

# Update metadata
meta <- readRDS("site/shinylive/webr/packages/metadata.rds")
meta$vctrs$assets[[1]]$filename <- structure("vctrs_0.6.5.tgz", class = "glue")
meta$vctrs$path <- structure("packages/vctrs/vctrs_0.6.5.tgz", class = "glue")
saveRDS(meta, "site/shinylive/webr/packages/metadata.rds")

cat("Replaced vctrs with 0.6.5 for rlang 1.1.6 compatibility\n")
