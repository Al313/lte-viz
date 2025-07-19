
rmarkdown::render("src/misc/www/manual.rmd", output_file = "manual.html")



# Server module for Manual tab
tab0Server <- function(id) {
    moduleServer(id, function(input, output, session) {

        observeEvent(input$goto_introduction, {
            session$sendCustomMessage("scrollTo", list(id = "introduction"))
        })

        observeEvent(input$goto_data_upload, {
            session$sendCustomMessage("scrollTo", list(id = "dataUpload"))
        })

        observeEvent(input$goto_data_table, {
            session$sendCustomMessage("scrollTo", list(id = "dataTable"))
        })

        observeEvent(input$goto_genome_browser, {
            session$sendCustomMessage("scrollTo", list(id = "genomeBrowser"))
        })

        observeEvent(input$goto_variant_tracker, {
            session$sendCustomMessage("scrollTo", list(id = "frequencyTracker"))
        })
    })
}

