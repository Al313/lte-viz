


tab2UI <- function(id) {
  ns <- NS(id)

  # Load data
  variant_data <- readRDS("data/variants_ann_expiii.rds") 
  # Set variables
  exp_line_factor <- c("MT-2_1","MT-2_2","MT-4_1","MT-4_2")
  feature_factor <- c("All","5R","5UTR","5LTRLS","gag","pol","vif","vpr","tat","rev","vpu","env","nef","3UTR","3R")
  impact_factor <- c("Any","U","S","N")
  names(impact_factor) <- c("All","Untranslated","Synonymous","Non-synonymous")

  tabPanel("Variant Table",
    sidebarPanel(
      tags$h3("Input:"),
      
      checkboxGroupInput(ns("lineage"), 
        label = "Select lineage(s):",
        choices = c("MT-2_1", "MT-2_2", "MT-4_1", "MT-4_2"),
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

      selectInput(ns("trans_impact"),
        label = "Translational Impact(s):",
        choices = c("Select All", "Untranslated", "Synonymous", "Non-synonymous"),
        multiple = TRUE,
        selected = "Untranslated"),
      

      # checkboxGroupInput(ns("trans_impact"), 
      #   label = "Translational Impact(s):",
      #   choices = c("Untranslated", "Synonymous", "Non-synonymous")),

      # checkboxInput(ns("trans_impact_all_or_none"), label = "All/None", value = TRUE),

      # br(),

      radioButtons(ns("filter_mode"), 
        label = "Filter by:",
        choices = c("Position", "Feature"),
        selected = "Position"),

      conditionalPanel(condition = sprintf("input['%s'] == 'Position'", ns("filter_mode")),
        textInput(ns("position"), label = "Position:", value = "678", placeholder = "678 or 678-700")
      ),

      conditionalPanel(condition = sprintf("input['%s'] == 'Feature'", ns("filter_mode")),
        checkboxGroupInput(ns("feature"), 
          label = "Feature(s):",
          choices = c("5R","5UTR","5LTRLS","gag","pol","vif","vpr","tat","rev","vpu","env","nef","3UTR","3R")),
        checkboxInput(ns("feature_all_or_none"), label = "All/None", value = TRUE)
      )
    ),

    # Main panel always shown
    mainPanel(
      DTOutput(ns("DT_out"))
    )
  )
}
