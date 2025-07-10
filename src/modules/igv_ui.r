


# Define UI
tab2UI <- function(id) {
    ns <- NS(id)
    tabPanel("IGV Genome Browser",
        sidebarPanel(
            helpText("Load variant tracks over the HIV genome."),
            br(),
            actionButton(ns("addGenomicFeatures"), "Add Genomic Features"),
            hr(),
            actionButton(ns("addVariantTrack"), "Add Variant Track"),
            div(id = ns("variantTracksContainer")),
            hr(),
            actionButton(ns("removeUserTracks"), "Remove User Tracks"),
            width = 3
            ),
            mainPanel(
            igvShinyOutput(ns('igv_browser')),
            width = 9
        )
    )
}
