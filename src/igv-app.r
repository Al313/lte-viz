####################################

####################################

# Load R packages
library(shiny)
library(shinythemes)
library(igvShiny)

# BiocManager::install("igvShiny")



# First, create genome options using parseAndValidateGenomeSpec
options <- parseAndValidateGenomeSpec(
  genomeName = "hg38", 
  initialLocus = "chr1:1-10000"
)

# Define UI
ui <- fluidPage(
  titlePanel("IGV Genome Browser"),
  igvShinyOutput("igv_browser")
)

# Define server logic
server <- function(input, output, session) {
  output$igv_browser <- renderIgvShiny({
    igvShiny(options)  # Pass the options object, not individual parameters
  })
}

# Run the application
shinyApp(ui = ui, server = server)










library(igvShiny)
library(shiny)

# Use the built-in test data that comes with igvShiny
data_directory <- system.file(package = "igvShiny", "extdata")
fasta_file <- file.path(data_directory, "ribosomal-RNA-gene.fasta")
fasta_index_file <- file.path(data_directory, "ribosomal-RNA-gene.fasta.fai")
annotation_file <- file.path(data_directory, "ribosomal-RNA-gene.gff3")


# Use the built-in test data that comes with igvShiny
fasta_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/hiv-nl43.fasta")
fasta_index_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/hiv-nl43.fasta.fai")
annotation_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/hiv-nl43-annotation.gff3")



# Create genome options
options <- parseAndValidateGenomeSpec(
  genomeName = "Ribosomal RNA Test Genome",
  initialLocus = "U13369.1:7,276-8,225",
  stockGenome = FALSE,
  dataMode = "localFiles",
  fasta = fasta_file,
  fastaIndex = fasta_index_file,
  genomeAnnotation = annotation_file
)

# Print the options to verify
print(options)

# Define UI
ui <- fluidPage(
  titlePanel("Test Custom Genome Browser"),
  igvShinyOutput("igv_browser")
)

# Define server logic
server <- function(input, output, session) {
  output$igv_browser <- renderIgvShiny({
    igvShiny(options)
  })
}

# Run the application
shinyApp(ui = ui, server = server)


# Load required libraries
library(shiny)
library(igvShiny)
library(VariantAnnotation)  # For reading VCF files

# Use the built-in test data that comes with igvShiny
fasta_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/hiv-nl43.fasta")
fasta_index_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/hiv-nl43.fasta.fai")
annotation_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/hiv-nl43-annotation.gff3")

# Define variant files
vcf_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/hiv-nl43-variants.vcf.gz")
vcf_index <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/hiv-nl43-variants.vcf.gz.csi")
genome_name <- "AF324493.2"

# Create genome options
options <- parseAndValidateGenomeSpec(
  genomeName = genome_name,
  initialLocus = "contig_1:1-50000",
  stockGenome = FALSE,
  dataMode = "localFiles",
  fasta = fasta_file,
  fastaIndex = fasta_index_file,
  genomeAnnotation = annotation_file
)

ui <- fluidPage(
  titlePanel("Custom Genome with Variants"),

  sidebarLayout(
    sidebarPanel(
      actionButton("load_coverage", "Load Coverage Track"),
      br(),
      helpText("This IGV viewer displays coverage tracks over the custom HIV genome."),
      br(),
      actionButton("load_variants", "Load Variants"),
      actionButton("clear_tracks", "Clear Variant Tracks")
    ),

    mainPanel(
      igvShinyOutput("igv_browser")
    )
  )
)

server <- function(input, output, session) {
  
  # Initialize IGV
  output$igv_browser <- renderIgvShiny({
    igvShiny(options)
  })
  
  observeEvent(input$load_coverage, {
    loadTrack(
      session = session,
      elementId = "igv_browser",
      trackName = "Coverage",
      trackType = "wig",
      trackUrl = "/Users/alimos313/Desktop/scrap/bam-portal/coverage.bw",
      color = "blue",
      trackHeight = 60
    )
  })

  # Load variant track when button is clicked
  observeEvent(input$load_variants, {
    # Method 1: Try loading VCF as Bioconductor object
    tryCatch({
      # Read VCF file using VariantAnnotation
      vcf_data <- readVcf(vcf_file, genome_name)
      head(vcf_data)
      rowRanges(vcf_data)

      loadVcfTrack(
        session = session,
        id = "igv_browser",
        trackName = "My Variants", 
        vcfData = vcf_data,
        displayMode = "EXPANDED"
      )
      showNotification("VCF track loaded successfully!", type = "message")
    }, error = function(e1) {
      # Method 2: Try with different parameter names
      tryCatch({
        loadVcfTrack(
          session = session,
          id = "igv_browser", 
          trackName = "My Variants",
          vcfURL = vcf_file,
          indexURL = vcf_index
        )
        showNotification("VCF track loaded successfully!", type = "message")
      }, error = function(e2) {
        # Method 3: Try minimal parameters
        tryCatch({
          loadVcfTrack(
            session = session,
            id = "igv_browser",
            vcfData = readVcf(vcf_file, "hg38")
          )
          showNotification("VCF track loaded successfully!", type = "message")
        }, error = function(e3) {
          showNotification(
            paste("Error loading VCF track:", e3$message, "Original error:", e1$message),
            type = "error",
            duration = 15
          )
        })
      })
    })
  })
  
  # Clear tracks when button is clicked
  observeEvent(input$clear_tracks, {
    tryCatch({
      removeUserAddedTracks(
        session = session,
        id = "igv_browser"  # Changed from elementId to id
      )
      showNotification("Tracks cleared successfully!", type = "message")
    }, error = function(e) {
      showNotification(
        paste("Error clearing tracks:", e$message),
        type = "error"
      )
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)









library(igvShiny)
demo_app_file <-
system.file(package = "igvShiny", "demos", "igvShinyDemo-withVCF.R")
if (interactive()) {
  shiny::runApp(demo_app_file)
}
