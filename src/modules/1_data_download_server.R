

# Server module for tab1
tab1Server <- function(id) {
    moduleServer(id, function(input, output, session) {

        ## Enable / disable download button
        observe({
            if (input$dataSourceChoice == "LTEE HIV-1 EXP-SB") {
                shinyjs::disable("DownloadData")
                showNotification(
                        "Data for LTEE HIV-1 EXP-SB is not available yet.",
                        type = "warning",
                        duration = 5
                )
            } else {
                shinyjs::enable("DownloadData")
            }
        })  

        output$DownloadData <- downloadHandler(

            ## filename the user sees
            filename = function() {

                if (input$dataSourceChoice == "LTEE HIV-1 EXP-SB") {
                    return(NULL)
                }

                paste0(
                    "filtered_variants.",
                    tolower(input$dataFormatChoice),
                    ".gz"
                )
            },

            ## what actually happens on click
            content = function(file) {

                ## EXP-SB → block download + message
                if (input$dataSourceChoice == "LTEE HIV-1 EXP-SB") {
                    showNotification(
                        "Data for LTEE HIV-1 EXP-SB is not available yet.",
                        type = "warning",
                        duration = 5
                    )
                    return(NULL)
                }

                ## EXP-2E → select file
                src_file <- switch(
                    input$dataFormatChoice,
                    "VCF" = "data/igv-input/plasmid/filtered_variants.vcf.gz",
                    "CSV" = "data/igv-input/plasmid/filtered_variants.csv.gz"
                )

                ## safety check
                if (!file.exists(src_file)) {
                    showNotification(
                        "Requested file does not exist on the server.",
                        type = "error",
                        duration = 5
                    )
                    return(NULL)
                }

                showNotification("Downloading selected data...", type = "message", duration = 5)

                file.copy(src_file, file)
            }
        )
    })
}
