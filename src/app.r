

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
library(VariantAnnotation)  # For reading VCF files



# set working directory path
if (file.exists("/home/amovas/")){
    print("Remote HPC Connection!")
    wd <- "/home/amovas/data/lte-viz/"
} else {
    print("Local PC Connection!")
    wd <- "/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/"
}

# load data
variant_data <- readRDS(paste0(wd, "data/variants_ann_expiii.rds"))

# set variables

line_col_palette <- c("#ff00ff", "#ff2400", "#6600cc", "#0000ff")
names(line_col_palette) <- c("MT-2_1", "MT-2_2", "MT-4_1", "MT-4_2")
exp_line_factor <- c("MT-2_1", "MT-2_2", "MT-4_1", "MT-4_2")
feature_factor <- unique(variant_data$feature)
impact_factor <- c("A", "U", "S", "N")
names(impact_factor) <- c("Any", "Untranslated", "Synonymous", "Non-synonymous")


# load modules
source(paste0(wd, "src/modules/data_upload_ui.r"))
source(paste0(wd, "src/modules/data_upload_server.r"))


source(paste0(wd, "src/modules/data_table_ui.r"))
source(paste0(wd, "src/modules/data_table_server.r"))

source(paste0(wd, "src/modules/igv_ui.r"))
source(paste0(wd, "src/modules/igv_server.r"))


source(paste0(wd, "src/modules/freq_tracker_ui.r"))
source(paste0(wd, "src/modules/freq_tracker_server.r"))




ui <- fluidPage(
    theme = shinytheme("readable"),
    navbarPage("LTEviz",
        tab0UI("tab0"),
        tab1UI("tab1"),
        tab2UI("tab2"),
        tab3UI("tab3")
    )
)

server <- function(input, output, session) {
    tab0Server("tab0")
    tab1Server("tab1")
    tab2Server("tab2",
        options = options,
        annotation_file = annotation_file)
    tab3Server("tab3")
}

shinyApp(ui, server)
