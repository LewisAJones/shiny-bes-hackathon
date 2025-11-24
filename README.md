# British Ecological Society (BES) Hack-a-thon

This repository contains the source code for the Shiny app accompaniment to:

> [REFERENCE PLACEHOLDER]

The purpose of this Shiny app is to support the exploration and visualisation of data generated during the BES hack-a-thon focused on understanding whether data (and code) from published papers in BES journals (plus Ecology and Evolution) are:

- [Open and FAIR](https://www.go-fair.org/fair-principles/)
- Being used by others
- Equitably collected and acknowledged

## Usage

Export the Shiny application in `app` to `docs` to create a Shinylive applications:

```
shinylive::export("app", "docs")
```

Preview the application by running a web server and visiting it in a browser:

```
httpuv::runStaticServer("docs/")
```