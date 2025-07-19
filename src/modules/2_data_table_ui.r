

tab2UI <- function(id, exp_line_factor, impact_factor, feature_factor) {
  ns <- NS(id)
  tabPanel("Variant Table",
    # Wrap everything in a sidebarLayout
    sidebarLayout(
      # Sidebar panel inside a conditionalPanel
      sidebarPanel(
        conditionalPanel(
          condition = "output.dataReady",
          tags$h3("Input:"),
          
          checkboxGroupInput(ns("lineage"), 
            label = "Select lineage(s):",
            choices = exp_line_factor,
            selected = "MT-2_1"),

          selectInput(ns("passage"), 
            label = "Passage:", 
            choices = as.character(seq(10, 500, 10)),
            selected = "100"),

          sliderInput(ns("af_range"), 
            label = "Allele Frequency Range:",
            min = 0, max = 1,
            value = c(0.01, 1),
            step = 0.01),

          checkboxGroupInput(ns("trans_impact"), 
            label = "Translational Impact(s):",
            choices = names(impact_factor),
            selected = "Any"),

          radioButtons(ns("filter_mode"), 
            label = "Filter by:",
            choices = c("Position", "Feature"),
            selected = "Position"),

          conditionalPanel(condition = sprintf("input['%s'] == 'Position'", ns("filter_mode")),
            textInput(ns("position"), label = "Position:", value = "678", placeholder = "678 or 678-700")),

          conditionalPanel(condition = sprintf("input['%s'] == 'Feature'", ns("filter_mode")),
            checkboxGroupInput(ns("feature"), "Feature(s):",
              choices = c("All", feature_factor),
              selected = "All"))
        )
      ),
      
      # Main panel always shown
      mainPanel(
        uiOutput(ns("mainContent"))
      )
    ) # sidebarLayout
  )
}
