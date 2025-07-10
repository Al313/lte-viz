


# Define UI
tab3UI <- function(id) {
    ns <- NS(id)
    tabPanel("Frequency Tracker",
        sidebarPanel(
        tags$h3("Input:"),
        
        # Lineage input
        checkboxGroupInput(ns("lineage"), 
            label="Select lineage(s):",
            choices = exp_line_factor,
            selected = "MT-2_1"),
        
        textInput(ns("mutCase"), label="Insert variant id:", 
            value="566_G_A", 
            placeholder="format: position_ref_alt (e.g., 566_G_A)"),

        ), # sidebarPanel
        mainPanel(
                    h1("Variant Trajectory"),
                    plotlyOutput(ns("variant_plot"))

        ) # mainPanel
        
    )
}