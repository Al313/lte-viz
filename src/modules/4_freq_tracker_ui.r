



# Define UI
tab4UI <- function(id) {
    ns <- NS(id)
    tabPanel("Frequency Dynamics",
        sidebarPanel(
            tags$h3("Input:"),
            # Lineage input

            radioButtons(ns("freq_mode"), 
                label = "Display mode:",
                choices = c("Frequency trajectory", "Frequency distribution"),
                selected = "Frequency trajectory"),

            conditionalPanel(condition = sprintf("input['%s'] == 'Frequency trajectory'", ns("freq_mode")),

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
            )

            
        ),

        mainPanel(
            conditionalPanel(
                condition = sprintf("input['%s'] == 'Frequency trajectory'", ns("freq_mode")),
                plotlyOutput(ns("mutation_plot"), width = "100%", height = "700px")
            ),
            conditionalPanel(
                condition = sprintf("input['%s'] == 'Frequency distribution'", ns("freq_mode")),
                imageOutput(ns("mutation_gif"), width = "100%")
            )
        )
    )
}