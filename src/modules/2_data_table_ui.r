

tab2UI <- function(id) {
  ns <- NS(id)

  # Load data
  variant_data <- readRDS("data/variants_ann_expiii.rds") 

  # Set variables
  line_col_palette <- c("#ff00ff", "#ff2400", "#6600cc", "#0000ff")
  names(line_col_palette) <- c("MT-2_1", "MT-2_2", "MT-4_1", "MT-4_2")
  exp_line_factor <- c("MT-2_1", "MT-2_2", "MT-4_1", "MT-4_2")
  feature_factor <- unique(variant_data$feature)
  impact_factor <- c("A", "U", "S", "N")
  names(impact_factor) <- c("Any", "Untranslated", "Synonymous", "Non-synonymous")

  tabPanel("Variant Table",
    # Wrap everything in a sidebarLayout
  
    # Sidebar panel inside a conditionalPanel
    sidebarPanel(
      
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
    
    ),
    
    # Main panel always shown
    mainPanel(
      uiOutput(ns("mainContent"))
    )
  
  )
}
