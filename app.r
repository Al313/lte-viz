

# Load R packages
library(shiny)
library(shinythemes)
library(igvShiny)
library(DT)
library(tidyr)
library(dplyr)
library(stringr)
library(magrittr)
library(ggplot2)
library(plotly)
library(VariantAnnotation)  # For reading and processing VCF files
library(rsconnect)

# Load data
variant_data <- readRDS("data/variants_ann_expiii.rds") 

# Set variables
line_col_palette <- c("#ff00ff", "#ff2400", "#6600cc", "#0000ff")
names(line_col_palette) <- c("MT-2_1", "MT-2_2", "MT-4_1", "MT-4_2")
exp_line_factor <- c("MT-2_1", "MT-2_2", "MT-4_1", "MT-4_2")
feature_factor <- unique(variant_data$feature)
impact_factor <- c("A", "U", "S", "N")
names(impact_factor) <- c("Any", "Untranslated", "Synonymous", "Non-synonymous")


# setwd("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/")


# load modules
invisible(lapply(list.files(path = "src/modules", pattern = "\\.r$", full.names = TRUE), source))


ui <- fluidPage(
    theme = shinytheme("readable"),
    navbarPage("LTEviz",
        tab0UI("tab0"),
        tab1UI("tab1")
        # tab2UI("tab2", exp_line_factor, impact_factor, feature_factor)
        # tab3UI("tab3")
        # tab4UI("tab4")
    )
)

server <- function(input, output, session) {
    
    # define a variable for data upload
    dataUploaded <- reactiveVal(FALSE)

    # define an output variable to make the input fields conditional
    output$dataReady <- reactive({
        dataUploaded()
    })

    outputOptions(output, "dataReady", suspendWhenHidden = FALSE)

    tab0Server("tab0")
    tab1Server("tab1", dataUploaded)
    # tab2Server("tab2", dataUploaded, feature_factor, impact_factor, variant_data)
    # tab3Server("tab3",
    #     options = options,
    #     annotation_file = annotation_file)
    # tab4Server("tab4")
}

shinyApp(ui, server)



# rsconnect::setAccountInfo(name='lteeviz',
# 			token='5060F436947E75F8FD3D89A0D53D593B',
# 			secret='+JxOeaWPaNZZlWs5De+6ubpVgh4UCgUygFdiL6dB')


# rsconnect::deployApp('/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz')

# BiocManager::install(version = "3.19") # or the latest available
# BiocManager::install(update = TRUE, ask = FALSE)
