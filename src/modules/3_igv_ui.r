


# Define UI
tab3UI <- function(id) {
    ns <- NS(id)
    tabPanel("Genome Browser",
        fluidRow(
            # Sidebar panel
            column(2,
                wellPanel(
                    helpText(paste0("Load variant tracks over the HIV-1 genome.")),
                    br(),
                    actionButton(ns("addGenomicFeatures"), "Add Genomic Features"),
                    hr(),
                    actionButton(ns("addVariantTrack"), "Add Variant Track"),
                    hr(),
                    actionButton(ns("removeUserTracks"), "Remove User Tracks")
                )
            ),
            # Variant tracks container - horizontal layout next to sidebar
            column(10,
                div(id = ns("variantTracksContainer"), 
                    style = "display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 20px; min-height: 50px;")
            )
        ),
        # IGV browser below both sidebar and variant tracks
        fluidRow(
            column(12,
                igvShinyOutput(ns('igv_browser'))
            )
        )
    )
}