


tab2UI <- function(id) {
  ns <- NS(id)

  tabPanel("Mutation Table",
    sidebarPanel(
      tags$h3("Input:"),
      
      checkboxGroupInput(ns("lineage"), 
        label = "Select lineage(s):",
        choices = c("MT-2_1", "MT-2_2", "MT-4_1", "MT-4_2"),
        selected = "MT-2_1"),

      selectInput(ns("passage"), 
        label = "Transfer:", 
        choices = as.character(seq(10, 500, 10)),
        selected = "100"),

      sliderInput(ns("af_range"), 
        label = "Variant Frequency Range:",
        min = 0, max = 1,
        value = c(0.01, 1),
        step = 0.01),
      

      radioButtons(ns("filter_mode"), 
        label = "Filter by:",
        choices = c("Feature", "Position"),
        selected = "Feature"),

      conditionalPanel(condition = sprintf("input['%s'] == 'Feature'", ns("filter_mode")),
          selectInput(ns("trans_impact"),
            label = "Translational Impact(s):",
            choices = c("Select All", "Untranslated", "Synonymous", "Non-synonymous"),
            multiple = TRUE,
            selected = "Untranslated"),
        
        checkboxGroupInput(ns("feature"), 
          label = "Feature(s):",
          choices = c("5R","5UTR","5LTRLS","gag","pol","vif","vpr","tat","rev","vpu","env","nef","3UTR","3R")),

        checkboxInput(ns("feature_all_or_none"), label = "All/None", value = TRUE)

      ),

      conditionalPanel(condition = sprintf("input['%s'] == 'Position'", ns("filter_mode")),
        textInput(ns("position"), label = "Position:", value = "678", placeholder = "678 or 678-700")
      )


    ),

    # Main panel always shown
    mainPanel(
      DTOutput(ns("DT_out"))
    )
  )
}
