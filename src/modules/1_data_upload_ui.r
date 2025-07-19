


# Define UI
tab1UI <- function(id) {
    ns <- NS(id)
    tabPanel("Data Upload",
        sidebarPanel(
            tags$h2("Data source:"),

            radioButtons(ns("dataSourceChoice"), 
                label="Choose the source of data:",
                choices = c("LTEE HIV-1", "Own data"),
                selected = "LTEE HIV-1"
            ),
            
            conditionalPanel(condition = sprintf("input['%s'] == 'LTEE HIV-1'", ns("dataSourceChoice")),
                hr(),
                tags$h3("Data loading:"),
                actionButton(ns("preLoadData"), "Load LTEE HIV-1 data")
            ),
            
            conditionalPanel(condition = sprintf("input['%s'] == 'Own data'", ns("dataSourceChoice")),
                hr(),
                tags$h3("Data loading:"),
                textInput(ns("genomeName"), label="Insert genome name:"),
                textInput(ns("fastaPath"), label="Insert path to reference genome (FASTA):"),
                textInput(ns("annotationPath"), label="Insert path to annotation file (GFF3):"),
                textInput(ns("variantPath"), label="Insert path to variant file (VCF):"),
                br(),
                actionButton(ns("loadFiles"), "Load all files")
            )
        ),

        mainPanel(
                uiOutput(ns('uploadMessage')),  # for success message
                width = 10
        )
    )
}