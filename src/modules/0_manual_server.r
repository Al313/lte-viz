
rmarkdown::render("src/misc/www/manual.Rmd", output_file = "manual.html")



# Server module for Manual tab
tab0Server <- function(id) {
    moduleServer(id, function(input, output, session) {

        observeEvent(input$goto_introduction, {
            session$sendCustomMessage("scrollTo", list(id = "introduction"))
        })

        observeEvent(input$goto_data_access, {
            session$sendCustomMessage("scrollTo", list(id = "dataAccess"))
        })

        observeEvent(input$goto_mutation_table, {
            session$sendCustomMessage("scrollTo", list(id = "mutationTable"))
        })

        observeEvent(input$goto_genome_browser, {
            session$sendCustomMessage("scrollTo", list(id = "genomeBrowser"))
        })

        observeEvent(input$goto_freq_dynamics, {
            session$sendCustomMessage("scrollTo", list(id = "mutationFrequencyDynamics"))
        })

        observeEvent(input$goto_pub_figures, {
            session$sendCustomMessage("scrollTo", list(id = "publicationFigures"))
        })
    })
}

