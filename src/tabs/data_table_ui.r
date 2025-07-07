# load data
variant_data <- readRDS(paste0("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/variants_ann_expiii.rds"))


exp_line_factor <- c("MT-2_1", "MT-2_2", "MT-4_1", "MT-4_2")
feature_factor <- unique(variant_data$feature)
impact_factor <- c("A", "U", "S", "N")
names(impact_factor) <- c("Any", "Untranslated", "Synonymous", "Non-synonymous")


# Define UI
tab1UI <- function(id) {
    ns <- NS(id)
    tabPanel("Variant Table",
        sidebarPanel(
        tags$h3("Input:"),
        
        # Lineage input
        checkboxGroupInput(ns("lineage"), 
            label="Select lineage(s):",
            choices = exp_line_factor,
            selected = "MT-2_1"),
        
        # Passage input
        selectInput(ns("passage"), 
            label="Passage:", 
            choices = as.character(seq(10, 500, 10)),
            selected = "100"),
        
        # Allele frequency range input
        sliderInput(ns("af_range"), 
            label="Allele Frequency Range:",
            min = 0, max = 1,
            value = c(0.01, 1),
            step = 0.01),
        
        # Translational impact input
        checkboxGroupInput(ns("trans_impact"), 
            label="Translational Impact(s):",
            choices = names(impact_factor),
            selected = "Any"),
        
        radioButtons(ns("filter_mode"), 
            label="Filter by:",
            choices = c("Position", "Feature"),
            selected = "Position"),
        
        # Position input (shown only when 'Position' selected)
        conditionalPanel(condition = sprintf("input['%s'] == 'Position'", ns("filter_mode")),
            textInput(ns("position"), label="Position:", value="678", placeholder="678 0r 678-700")),
        
        # Feature input (shown only when 'Feature' selected)
        conditionalPanel(condition = sprintf("input['%s'] == 'Feature'", ns("filter_mode")),
            checkboxGroupInput(ns("feature"), "Feature(s):",
                            choices = c("All", feature_factor),
                            selected = "All"))
        

        ), # sidebarPanel
        mainPanel(
                    h1("Variant Table"),
                    
                    DTOutput(ns("DT_out"))

        ) # mainPanel
        
    )
}