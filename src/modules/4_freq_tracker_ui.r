


# Define UI
tab4UI <- function(id) {
    ns <- NS(id)
    tabPanel("Frequency Tracker",
        sidebarPanel(
            tags$h3("Input:"),
            # Lineage input
            checkboxGroupInput(ns("lineage"), 
                label="Select lineage(s):",
                choices = c("MT-2_1","MT-2_2","MT-4_1","MT-4_2"),
                selected = "MT-2_1"),

            textInput(ns("mutCase1"), label="Insert first mutation id:", 
                value="566_G_A", 
                placeholder="format: position_ref_alt (e.g., 566_G_A)"),
            
            textInput(ns("mutCase2"), label="Insert second mutation id (optional):", 
                value="", 
                placeholder="format: position_ref_alt (e.g., 972_G_A)")
            ),

            mainPanel(
                h1("Mutation Trajectory"),
                plotlyOutput(ns("mutation_plot"), width = "100%", height = "700px")
        )
    )
}