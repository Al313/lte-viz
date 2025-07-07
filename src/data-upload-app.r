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




ui <- fluidPage(theme = shinytheme("readable"),  # <--- To use a theme, comment this line
    navbarPage(
        "LTEEviz",
        tabPanel("Data Upload",
            sidebarPanel(
                tags$h2("Data source:"),

                radioButtons(inputId="dataSourceChoice", 
                    label="Choose the source of data:",
                    choices = c("LTEE HIV-1", "Own data"),
                    selected = "LTEE HIV-1"
                ),
                
                conditionalPanel(condition = "input.dataSourceChoice == 'LTEE HIV-1'",
                    hr(),
                    tags$h3("Data loading:"),
                    actionButton("preLoadData", "Load LTEE HIV-1 data")
                ),
                
                conditionalPanel(condition = "input.dataSourceChoice == 'Own data'",
                    hr(),
                    tags$h3("Data loading:"),
                    textInput("genomeName", label="Insert genome name:"),
                    textInput("fastaPath", label="Insert path to reference genome (FASTA):"),
                    textInput("annotationPath", label="Insert path to annotation file (GFF3):"),
                    textInput("variantPath", label="Insert path to variant file (VCF):"),
                    br(),
                    actionButton("loadFiles", "Load all files")
                )
            ),

            mainPanel(
                igvShinyOutput('igv_browser'),
                width=10
            )
        )
    )
)


server <- function(input, output, session) {
    
    
    # Create genome options
    genomeOptionsPreload <- eventReactive(input$preLoadData, {

        # Use input data for HIV-1 genome
        genome_name <- "HIV-NL4_3"
        fasta_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/igv-input/plasmid/reference.fasta")
        annotation_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/igv-input/plasmid/annotation.gff3")
        vcf_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/igv-input/plasmid/filtered_variants.vcf.gz")
    
        parseAndValidateGenomeSpec(
            genomeName = genome_name,
            # initialLocus = "AF324493.2:600-700",
            stockGenome = FALSE,
            dataMode = "localFiles",
            fasta = fasta_file,
            fastaIndex = paste0(fasta_file, ".fai")
        )
    })
    
    # Create genome options
    genomeOptionsCustom <- eventReactive(input$loadFiles, {
        validate(
            need(input$genomeName != "", "⚠️ Please provide a genome name."),
            need(input$fastaPath != "", "⚠️ Please provide the path to the reference genome (FASTA).")
            # need(input$annotationPath != "", "⚠️ Please provide the path to the annotation file (GFF3)."),
            # need(input$variantPath != "", "⚠️ Please provide the path to the variant file (VCF).")
        )

        validate(
            need(file.exists(input$fastaPath), "❌ The FASTA file path does not exist."),
            need(file.exists(paste0(input$fastaPath, ".fai")), "❌ The FASTA index file (.fai) is missing.")
            # need(file.exists(input$annotationPath), "❌ The GFF3 file path does not exist."),
            # need(file.exists(input$variantPath), "❌ The VCF file path does not exist."),
            # need(file.exists(input$variantPath), "❌ The VCF index file (.csi) does not exist.")
        )
    
        parseAndValidateGenomeSpec(
            genomeName = input$genomeName,
            # initialLocus = "AF324493.2:600-700",
            stockGenome = FALSE,
            dataMode = "localFiles",
            fasta = input$fastaPath,
            fastaIndex = paste0(input$fastaPath, ".fai")
        )
    })
    
    # Conditional rendering based on input$dataSourceChoice
    output$igv_browser <- renderIgvShiny({
        if (input$dataSourceChoice == "LTEE HIV-1") {
            req(genomeOptionsPreload())
            igvShiny(genomeOptionsPreload())
        } else {
            req(genomeOptionsCustom())
            igvShiny(genomeOptionsCustom())
        }
    })
}


# Launch the Shiny app
shinyApp(ui = ui, server = server)
