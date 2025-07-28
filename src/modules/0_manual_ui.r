


# Define UI
tab0UI <- function(id) {
    ns <- NS(id)
    tabPanel("Manual",
        sidebarLayout(
            sidebarPanel(
                tags$h3("Quick Access"),

                tags$ul(
                    tags$li(actionLink(ns("goto_introduction"), "Introduction")),
                    tags$li(actionLink(ns("goto_data_upload"), "Data Upload")),
                    tags$li(actionLink(ns("goto_data_table"), "Data Table")),
                    tags$li(actionLink(ns("goto_genome_browser"), "Genome Browser")),
                    tags$li(actionLink(ns("goto_mutation_tracker"), "Mutation Frequency Tracker")),
                )
            ),

            mainPanel(
                tags$head(
                    tags$script(HTML("
                        Shiny.addCustomMessageHandler('scrollTo', function(message) {
                            var el = document.getElementById(message.id);
                            if (el) {
                                el.scrollIntoView({ behavior: 'smooth' });
                            }
                        });
                    "))
                ),
                includeHTML("src/misc/www/manual.html"),
                width = 10
            )
        )
    )
}


