

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




# setwd("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/")


# load modules
invisible(lapply(list.files(path = "src/modules", pattern = "\\.r$", full.names = TRUE), source))


ui <- fluidPage(
    theme = shinytheme("readable"),
    navbarPage("LTEviz",
        tab0UI("tab0"),
        tab1UI("tab1"),
        tab2UI("tab2")
        # tab3UI("tab3")
        # tab4UI("tab4")
    )
)

server <- function(input, output, session) {
    
    # # define a variable for data upload
    # dataUploaded <- reactiveVal(FALSE)

    # # define an output variable to make the input fields conditional
    # output$dataReady <- reactive({
    #     dataUploaded()
    # })

    # outputOptions(output, "dataReady", suspendWhenHidden = FALSE)

    tab0Server("tab0")
    tab1Server("tab1")
    tab2Server("tab2")
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
