


# Load R packages
library(shiny)
library(shinythemes)
library(igvShiny)
library(DT)
library(plotly)




# setwd("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/")


# load modules
invisible(lapply(list.files(path = "src/modules", pattern = "\\.R$", full.names = TRUE), source))



ui <- fluidPage(
    theme = shinytheme("readable"),
    navbarPage("LTEEviz",
        tab0UI("tab0"),
        tab1UI("tab1"),
        tab2UI("tab2"),
        tab3UI("tab3"),
        tab4UI("tab4")
    )
)

server <- function(input, output, session) {
    
    # Load data
    variant_data <- readRDS("data/variants_ann_expiii.rds") 
    # Set variables
    exp_line_factor <- c("MT-2_1","MT-2_2","MT-4_1","MT-4_2")
    feature_factor <- c("All","5R","5UTR","5LTRLS","gag","pol","vif","vpr","tat","rev","vpu","env","nef","3UTR","3R")
    impact_factor <- c("Any","U","S","N")
    names(impact_factor) <- c("All","Untranslated","Synonymous","Non-synonymous")



    tab0Server("tab0")
    tab1Server("tab1")
    tab2Server("tab2", variant_data = variant_data, impact_factor = impact_factor)
    tab3Server("tab3", options = options, annotation_file = annotation_file)
    tab4Server("tab4", variant_data = variant_data)
}

shinyApp(ui, server)



### app deployment 


# rsconnect::setAccountInfo(
#     name = "lteeviz",
#     token = "5060F436947E75F8FD3D89A0D53D593B",
#     secret = "+JxOeaWPaNZZlWs5De+6ubpVgh4UCgUygFdiL6dB"
# )

# rsconnect::deployApp(
#     appDir = "/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz",
#     account = "lteeviz",
#     appName = "lteeviz"  # Optional: give dev version a different app name
# )

# rsconnect::setAccountInfo(
#     name = "lteeviz-dev",
#     token = "D4E6D8044639F6BB1F271310A1FA85F8",
#     secret = "uJuIz0eTmNEQJGKtz1UyujuDqxWaudlp6nWsd+Ah"
# )

# rsconnect::deployApp(
#     appDir = "/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz",
#     account = "lteeviz-dev",
#     appName = "lteeviz-dev"  # Optional: give dev version a different app name
# )
