####################################

####################################

# Load R packages
library(shiny)
library(shinythemes)
library(igvShiny)
# BiocManager::install("igvShiny")

######################################################################
# simple IGV widget with default genome
######################################################################

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


######################################################################
# IGV widget with costume genome + genomic features
######################################################################

# Use input data for HIV-1 genome
fasta_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/igv-input/plasmid/reference.fasta")
fasta_index_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/igv-input/plasmid/reference.fasta.fai")
annotation_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/igv-input/plasmid/annotation.gff3")

genome_name <- "HIV-NL4_3"

# Create genome options
options <- parseAndValidateGenomeSpec(
  genomeName = genome_name,
  initialLocus = "AF324493.2:600-700",
  stockGenome = FALSE,
  dataMode = "localFiles",
  fasta = fasta_file,
  fastaIndex = fasta_index_file
)


# Define UI
ui <- fluidPage(
  titlePanel("IGV Genome Browser"),
  
  sidebarLayout(
    sidebarPanel(
      
      actionButton("addLocalGFF3TrackButtonWithBiotypeColors", "GFF3 Track (local) - colors"),
      actionButton("removeUserTracksButton", "Remove User Tracks"),
      br(), br(),
      hr(),
      width=2),

    mainPanel(
      igvShinyOutput('igv_browser'),
      width=10)

  ) # sidebarLayout
)



# Define server logic
server <- function(input, output, session) {


  output$igv_browser <- renderIgvShiny({
    igvShiny(options)  # Pass the options object, not individual parameters
  })

  observeEvent(input$addLocalGFF3TrackButtonWithBiotypeColors, {
    showGenomicRegion(session, id="igv_browser", "AF324493.2:600-700")
    full.path <- annotation_file
    tbl.gff3 <- read.table(full.path, sep="\t", as.is=TRUE, header=FALSE)
    colnames(tbl.gff3) <- c("seqname", "source", "feature", "start", "end",
                        "score", "strand", "frame", "attribute")
    sprintf("--- about to call loadGFF3rackFromLocalData, dim: %d, %d", nrow(tbl.gff3), ncol(tbl.gff3))
    color.table <- list(repeat_region="blue",
                        CDS="darkred",
                        Src="black")

    colorByAttribute <- "gbkey"
    loadGFF3TrackFromLocalData(session,
                              id="igv_browser",
                              trackName="Genomic Features",
                              tbl.gff3=tbl.gff3,
                              # color="brown",
                              colorTable=color.table,
                              colorByAttribute=colorByAttribute,
                              displayMode="EXPANDED",
                              trackHeight=200,
                              visibilityWindow=15000,
                              deleteTracksOfSameName=TRUE)
    }) # addLocalGFF3TrackButtonWithBiotypeColors

  observeEvent(input$removeUserTracksButton, {
      sprintf("---- removeUserTracks")
      removeUserAddedTracks(session, id="igv_browser")
      })

}

# Run the application
shinyApp(ui = ui, server = server)



######################################################################
# IGV widget with costume genome + a single variant track
######################################################################


# Load required libraries
library(VariantAnnotation)  # For reading VCF files

# Set paths to variant files
vcf_file <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/igv-input/plasmid/filtered_variants.vcf.gz")
vcf_index <- file.path("/Users/alimos313/Documents/studies/phd/hpc-research/lte-viz/data/igv-input/plasmid/filtered_variants.vcf.gz.csi")


# Create genome options
options <- parseAndValidateGenomeSpec(
  genomeName = genome_name,
  initialLocus = "AF324493.2:600-700",
  stockGenome = FALSE,
  dataMode = "localFiles",
  fasta = fasta_file,
  fastaIndex = fasta_index_file
)


# Define UI
ui <- fluidPage(
  titlePanel("IGV Genome Browser"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Load variant tracks over the HIV genome."),
      br(),
      actionButton("addGenomicFeatures", "Add Genomic Features"),
      hr(),
      # Lineage input
      selectInput(inputId="lineage", 
        label="Lineage:", 
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
      
      actionButton("loadVariants", "Load Variants"),
      hr(),
      actionButton("removeUserTracks", "Remove User Tracks"),
      width=2),

    mainPanel(
      igvShinyOutput('igv_browser'),
      width=10)

  ) # sidebarLayout
)




# Define server logic
server <- function(input, output, session) {

  output$igv_browser <- renderIgvShiny({
    igvShiny(options)  # Pass the options object, not individual parameters
  })

  observeEvent(input$addGenomicFeatures, {
    showGenomicRegion(session, id="igv_browser", "AF324493.2:600-700")
    full.path <- annotation_file
    tbl.gff3 <- read.table(full.path, sep="\t", as.is=TRUE, header=FALSE)
    colnames(tbl.gff3) <- c("seqname", "source", "feature", "start", "end",
                        "score", "strand", "frame", "attribute")
    sprintf("--- about to call loadGFF3rackFromLocalData, dim: %d, %d", nrow(tbl.gff3), ncol(tbl.gff3))
    color.table <- list(repeat_region="blue",
                        CDS="darkred",
                        Src="black")

    colorByAttribute <- "gbkey"
    loadGFF3TrackFromLocalData(session,
                              id="igv_browser",
                              trackName="Genomic Features",
                              tbl.gff3=tbl.gff3,
                              # color="brown",
                              colorTable=color.table,
                              colorByAttribute=colorByAttribute,
                              displayMode="EXPANDED",
                              trackHeight=200,
                              visibilityWindow=15000,
                              deleteTracksOfSameName=TRUE)
    })


  # Load variant track when button is clicked
  observeEvent(input$loadVariants, {
    # Read VCF file using VariantAnnotation
    vcf_data <- readVcf(vcf_file, genome_name)
    info_data <- info(vcf_data)
    # rowRanges(vcf_data)
    
    # Coerce to numeric (some may be returned as factor or character depending on the source)
    af <- as.numeric(info_data$AF)
    line <- as.integer(info_data$LINE)
    passage <- as.integer(info_data$PASSAGE)
    line_conversion_tbl <- c("MT-2_1" = 13, "MT-2_2" = 14, "MT-4_1" = 15, "MT-4_2" = 16)
    
    # Apply filtering
    selected <- which(line == line_conversion_tbl[input$lineage] & passage == input$passage & af >= input$af_range[1] & af <= input$af_range[2])
    # Extract filtered VCF object
    info_data_filtered <- vcf_data[selected]

    # Load the filtered VCF data into IGV
    loadVcfTrack(
      session = session,
      id = "igv_browser",
      trackName = "My Variants", 
      vcfData = info_data_filtered
    )
      
  })
  
  observeEvent(input$removeUserTracks, {
      sprintf("---- removeUserTracks")
      removeUserAddedTracks(session, id="igv_browser")
      })

}


# Run the application
shinyApp(ui = ui, server = server)





######################################################################
# IGV widget with costume genome + multiple variant tracks
######################################################################


exp_line_factor <- c("MT-2_1", "MT-2_2", "MT-4_1", "MT-4_2")
line_conversion_tbl <- c("MT-2_1" = 13, "MT-2_2" = 14, "MT-4_1" = 15, "MT-4_2" = 16)



options <- parseAndValidateGenomeSpec(
  genomeName = genome_name,
  initialLocus = "AF324493.2:600-700",
  stockGenome = FALSE,
  dataMode = "localFiles",
  fasta = fasta_file,
  fastaIndex = fasta_index_file
)

ui <- fluidPage(
  titlePanel("IGV Genome Browser"),
  sidebarLayout(
    sidebarPanel(
      helpText("Load variant tracks over the HIV genome."),
      br(),
      actionButton("addGenomicFeatures", "Add Genomic Features"),
      hr(),
      actionButton("addVariantTrack", "Add Variant Track"),
      div(id = "variantTracksContainer"),
      hr(),
      actionButton("removeUserTracks", "Remove User Tracks"),
      width = 3
    ),
    mainPanel(
      igvShinyOutput('igv_browser'),
      width = 9
    )
  )
)

server <- function(input, output, session) {
  
  rv <- reactiveValues(trackCount = 0)
  
  output$igv_browser <- renderIgvShiny({
    igvShiny(options)
  })
  
  observeEvent(input$addGenomicFeatures, {
    showGenomicRegion(session, id = "igv_browser", "AF324493.2:600-700")
    tbl.gff3 <- read.table(annotation_file, sep = "\t", as.is = TRUE, header = FALSE)
    colnames(tbl.gff3) <- c("seqname", "source", "feature", "start", "end",
                            "score", "strand", "frame", "attribute")
    
    color.table <- list(
      repeat_region = "blue",
      CDS = "darkred",
      Src = "black"
    )
    
    loadGFF3TrackFromLocalData(session,
                               id = "igv_browser",
                               trackName = "Genomic Features",
                               tbl.gff3 = tbl.gff3,
                               colorTable = color.table,
                               colorByAttribute = "gbkey",
                               displayMode = "EXPANDED",
                               trackHeight = 200,
                               visibilityWindow = 15000,
                               deleteTracksOfSameName = TRUE)
  })
  
  observeEvent(input$addVariantTrack, {
    rv$trackCount <- rv$trackCount + 1
    idx <- rv$trackCount
    ns <- paste0("_", idx)
    
    insertUI(
      selector = "#variantTracksContainer",
      where = "beforeEnd",
      ui = wellPanel(
        id = paste0("variantPanel", ns),
        h4(paste("Variant Track", idx)),
        selectInput(paste0("lineage", ns), "Lineage:", choices = exp_line_factor, selected = "MT-2_1"),
        selectInput(paste0("passage", ns), "Passage:", choices = as.character(seq(10, 500, 10)), selected = "100"),
        sliderInput(paste0("af_range", ns), "Allele Frequency Range:", min = 0, max = 1, value = c(0.01, 1), step = 0.01),
        actionButton(paste0("loadVariants", ns), "Load Variants")
      )
    )
  })
  
  observe({
    n <- rv$trackCount
    if (n == 0) return()
    
    for (i in seq_len(n)) {
      local({
        idx <- i
        ns <- paste0("_", idx)
        btnId <- paste0("loadVariants", ns)
        
        if (is.null(isolate(session$userData[[btnId]]))) {
          session$userData[[btnId]] <- TRUE
          
          observeEvent(input[[btnId]], {
            vcf_data <- readVcf(vcf_file, genome_name)
            info_data <- info(vcf_data)
            
            af <- as.numeric(info_data$AF)
            line <- as.integer(info_data$LINE)
            passage <- as.integer(info_data$PASSAGE)
            
            selected <- which(
              line == line_conversion_tbl[[input[[paste0("lineage", ns)]]]] &
              passage == as.integer(input[[paste0("passage", ns)]]) &
              af >= input[[paste0("af_range", ns)]][1] &
              af <= input[[paste0("af_range", ns)]][2]
            )
            
            filtered_vcf <- vcf_data[selected]
            
            loadVcfTrack(
              session = session,
              id = "igv_browser",
              trackName = paste0("Variant Track ", idx),
              vcfData = filtered_vcf
            )
          }, ignoreInit = TRUE)
        }
      })
    }
  })
  
  observeEvent(input$removeUserTracks, {
    removeUserAddedTracks(session, id = "igv_browser")
    rv$trackCount <- 0
    removeUI(selector = "#variantTracksContainer > *")  # Removes all variant panels
  })
}

# Run the application
shinyApp(ui, server)
