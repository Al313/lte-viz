


# Define UI
tab1UI <- function(id) {
    ns <- NS(id)
    tabPanel("Data Access",
        sidebarPanel(
            tags$h2("Dataset:"),

            radioButtons(ns("dataSourceChoice"), 
                label="Choose the source of data:",
                choices = c("LTEE HIV-1 EXP-2E", "LTEE HIV-1 EXP-SB"),
                selected = "LTEE HIV-1 EXP-2E"
            ),
            
            radioButtons(ns("dataFormatChoice"), 
                label="Choose the format of data:",
                choices = c("VCF", "CSV"),
                selected = "VCF"
            ),
            br(),
            actionButton(ns("DownloadData"), "Download Selected Data")
            # conditionalPanel(condition = sprintf("input['%s'] == 'LTEE HIV-1 EXP-2E'", ns("dataSourceChoice")),
            #     hr(),
            #     tags$h3("Data type:"),
            #     actionButton(ns("preLoadData"), "Load LTEE HIV-1 data")
            # ),
            
            # conditionalPanel(condition = sprintf("input['%s'] == 'Third-party data'", ns("dataSourceChoice")),
            #     hr(),
            #     tags$h3("Data loading:"),
            #     textInput(ns("genomeName"), label="Insert genome name:"),
            #     textInput(ns("fastaPath"), label="Insert path to reference genome (FASTA):"),
            #     textInput(ns("annotationPath"), label="Insert path to annotation file (GFF3):"),
            #     textInput(ns("variantPath"), label="Insert path to mutation file (VCF):"),
            #     br(),
            #     actionButton(ns("loadFiles"), "Load all files")
            # )
        ),

        mainPanel(
                uiOutput(ns('uploadMessage')),  # for success message
                width = 10
        )
    )
}