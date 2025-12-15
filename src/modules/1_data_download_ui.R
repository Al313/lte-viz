


# Define UI
tab1UI <- function(id) {
    ns <- NS(id)

    tabPanel(
        "Data Access",
        useShinyjs(),
        sidebarPanel(
            tags$h2("Dataset:"),

            radioButtons(
                ns("dataSourceChoice"),
                label = "Choose the source of data:",
                choices = c("LTEE HIV-1 EXP-2E", "LTEE HIV-1 EXP-SB"),
                selected = "LTEE HIV-1 EXP-2E"
            ),

            radioButtons(
                ns("dataFormatChoice"),
                label = "Choose the format of data:",
                choices = c("VCF", "CSV"),
                selected = "VCF"
            ),
            br(),
            downloadButton(ns("DownloadData"), "Download Selected Data")
        ),

        mainPanel(
            uiOutput(ns("downloadMessage")),
            width = 10
        )
    )
}
