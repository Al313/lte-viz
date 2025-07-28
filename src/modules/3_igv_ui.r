


# Define UI
tab3UI <- function(id) {
    ns <- NS(id)
    tabPanel("Genome Browser",
        useShinyjs(), 
        fluidRow(
            # Sidebar panel
            column(2,
                wellPanel(
                    helpText(paste0("Load mutation tracks over the HIV-1 genome.")),
                    br(),
                    actionButton(ns("addGenomicFeatures"), "Add Genomic Features"),
                    hr(),
                    actionButton(ns("addMutationTrack"), "Add Mutation Track"),
                    hr(),
                    actionButton(ns("removeUserTracks"), "Remove User Tracks")
                )
            ),
            # Mutation tracks container - horizontal layout next to sidebar
            column(10,
                div(id = ns("mutationTracksContainer"), 
                    style = "display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 20px; min-height: 50px;")
            )
        ),
        # IGV browser below both sidebar and mutation tracks
        fluidRow(
            column(12,
                igvShinyOutput(ns('igv_browser'))
            )
        )
    )
}