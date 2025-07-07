

# Load R packages
library(shiny)
library(shinythemes)
library(igvShiny)
library(DT)
library(dplyr)
library(stringr)
library(magrittr)
library(tidyr)
library(VariantAnnotation)  # For reading VCF files



# set working directory path
if (file.exists("/home/amovas/")){
    print("Remote HPC Connection!")
    wd <- "/home/amovas/data/genome-evo-proj/"
} else {
    print("Local PC Connection!")
    wd <- "/Users/alimos313/Documents/studies/phd/hpc-research/genome-evo-proj/"
}



source("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/src/tabs/data_upload_ui.r")
source("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/src/tabs/data_upload_server.r")


source("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/src/tabs/data_table_ui.r")
source("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/src/tabs/data_table_server.r")

source("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/src/tabs/igv_ui.r")
source("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/src/tabs/igv_server.r")






ui <- fluidPage(
    theme = shinytheme("readable"),
    navbarPage("LTEviz",
        tab0UI("tab0"),
        tab1UI("tab1"),
        tab2UI("tab2")
    )
)

server <- function(input, output, session) {
    tab0Server("tab0")
    tab1Server("tab1")
    tab2Server("tab2",
        options = options,
        annotation_file = annotation_file)
}

shinyApp(ui, server)
