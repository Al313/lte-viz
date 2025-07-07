####################################

####################################

# Load R packages
library(shiny)
library(shinythemes)
library(DT)
library(dplyr)
library(stringr)
library(magrittr)
library(tidyr)



# set working directory path
if (file.exists("/home/amovas/")){
  print("Remote HPC Connection!")
  wd <- "/home/amovas/data/genome-evo-proj/"
} else {
  print("Local PC Connection!")
  wd <- "/Users/alimos313/Documents/studies/phd/hpc-research/genome-evo-proj/"
}

# load data
variant_data <- readRDS(paste0("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/variants_ann_expiii.rds"))


exp_line_factor <- c("MT-2_1", "MT-2_2", "MT-4_1", "MT-4_2")
feature_factor <- unique(variant_data$feature)
impact_factor <- c("A", "U", "S", "N")
names(impact_factor) <- c("Any", "Untranslated", "Synonymous", "Non-synonymous")

# Define UI
ui <- fluidPage(theme = shinytheme("readable"),  # <--- To use a theme, comment this line
  navbarPage(
    "LTEEviz",
    tabPanel("Variant Table",
      sidebarPanel(
        tags$h3("Input:"),
        
        # Lineage input
        checkboxGroupInput(inputId="lineage", 
          label="Select lineage(s):",
          choices = exp_line_factor,
          selected = "MT-2_1"),
        
        # Passage input
        selectInput(inputId="passage", 
          label="Passage:", 
          choices = as.character(seq(10, 500, 10)),
          selected = "100"),
        
        # Allele frequency range input
        sliderInput(inputId="af_range", 
          label="Allele Frequency Range:",
          min = 0, max = 1,
          value = c(0.01, 1),
          step = 0.01),
        
        # Translational impact input
        checkboxGroupInput(inputId="trans_impact", 
          label="Translational Impact(s):",
          choices = names(impact_factor),
          selected = "Any"),
        
        radioButtons(inputId="filter_mode", 
          label="Filter by:",
          choices = c("Position", "Feature"),
          selected = "Position"),
        
        # Position input (shown only when 'Position' selected)
        conditionalPanel(condition = "input.filter_mode == 'Position'",
          textInput(inputId="position", label="Position:", value="678", placeholder="678 0r 678-700")),
        
        # Feature input (shown only when 'Feature' selected)
        conditionalPanel(condition = "input.filter_mode == 'Feature'",
          checkboxGroupInput("feature", "Feature(s):",
                            choices = c("All", feature_factor),
                            selected = "All"))
        

      ), # sidebarPanel
      mainPanel(
                  h1("Variant Table"),
                  
                  DTOutput("DT_out")

      ) # mainPanel
      
    ), # Navbar 1, tabPanel
    tabPanel("Genome Map", "This panel will display a genome browser in the future."),
    tabPanel("Frequency Dynamics", "This panel will display frequency dynamics in the future.")

  ) # navbarPage
) # fluidPage


# Define server function  
server <- function(input, output, session) {
  
  observe({
    # If "All" is selected in features, update to all features (except if already fully selected)
    if ("All" %in% input$feature && !all(feature_factor %in% input$feature)) {
      updateCheckboxGroupInput(session, "feature",
        selected = c("All", feature_factor))
    }

    # If "All" is deselected manually in features, remove it from selected
    if (!"All" %in% input$feature && all(feature_factor %in% input$feature)) {
      updateCheckboxGroupInput(session, "feature",
        selected = "gag")
    }

    # If "All" is selected in trans_impact, update to all impacts (except if already fully selected)
    if ("Any" %in% input$trans_impact && !all(names(impact_factor) %in% input$trans_impact)) {
      updateCheckboxGroupInput(session, "trans_impact",
        selected = c("Any", names(impact_factor)))
    }

    # If "Any" is deselected manually in trans_impact, remove it from selected
    if (!"Any" %in% input$trans_impact && all(names(impact_factor[-1]) %in% input$trans_impact)) {
      updateCheckboxGroupInput(session, "trans_impact",
        selected = "Untranslated")
    }
  })

  output$DT_out <- renderDT({
    
    pos_input <- gsub(" ", "", input$position)
    pos_range <- tryCatch({
      if (grepl("-", pos_input)) {
        bounds <- strsplit(pos_input, "-")[[1]]
        start <- as.numeric(bounds[1])
        end <- as.numeric(bounds[2])
        
        if (start > end) {
          showNotification("Start position is greater than end position. Please enter a valid range (e.g., 9510-9522).", type = "error")
          return(numeric(0))  # return empty so no match is made
        } else {
          seq(start, end)
        }
      } else {
        as.numeric(pos_input)
      }
    }, error = function(e) {
      showNotification("Invalid position format. Use a number or a range like 102-202.", type = "error")
      numeric(0)
    })

    # Remove "All" from the selection if present
    selected_features <- setdiff(input$feature, "All")
    selected_trans_impact <- setdiff(input$trans_impact, "All")
    
    subset <- variant_data[
      variant_data$exp_line %in% input$lineage &
      variant_data$passage == input$passage &
      variant_data$allele_freq >= input$af_range[1] &
      variant_data$allele_freq <= input$af_range[2] &
      variant_data$effect_simplified %in% impact_factor[selected_trans_impact], ]

    # Conditional filtering based on mode
    if (input$filter_mode == "Position") {
      subset <- subset[subset$genomic_pos %in% pos_range, ]
    } else if (input$filter_mode == "Feature") {
      subset <- subset[subset$feature %in% selected_features, ]
    } 
      
    datatable(subset, options = list(pageLength = 10))
  })
} # server


# Create Shiny object
# shinyApp(ui = ui, server = server)
runApp(list(ui = ui, server = server), launch.browser = TRUE)


