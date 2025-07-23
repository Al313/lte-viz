

# Set paths to input files
genome_name <- "HIV-NL4_3"
fasta_file <- file.path("data/igv-input/plasmid/reference.fasta")
annotation_file <- file.path("data/igv-input/plasmid/annotation.gff3")
vcf_file <- file.path("data/igv-input/plasmid/filtered_variants.vcf.gz")
line_conversion_tbl <- c("MT-2_1" = 13, "MT-2_2" = 14, "MT-4_1" = 15, "MT-4_2" = 16)



# Create genome options
options <- parseAndValidateGenomeSpec(
    genomeName = genome_name,
    initialLocus = "AF324493.2:600-700",
    stockGenome = FALSE,
    dataMode = "localFiles",
    fasta = fasta_file,
    fastaIndex = paste0(fasta_file, ".fai")
)




# Define server function


# Server module for tab3
tab3Server <- function(id, options, annotation_file) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns  # Namespace function for this module
        
        rv <- reactiveValues(trackCount = 0)
        
        output$igv_browser <- renderIgvShiny({
            igvShiny(options)
        })
        
        # Add genomic features track
        observeEvent(input$addGenomicFeatures, {
            showGenomicRegion(session, id = ns("igv_browser"), "AF324493.2:600-700")
            tbl.gff3 <- read.table(annotation_file, sep = "\t", as.is = TRUE, header = FALSE)
            colnames(tbl.gff3) <- c("seqname", "source", "feature", "start", "end",
                                    "score", "strand", "frame", "attribute")
            
            color.table <- list(
                repeat_region = "blue",
                CDS = "darkred",
                Src = "black"
            )
            
            loadGFF3TrackFromLocalData(session,
                                        id = ns("igv_browser"),
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
            # limit to 4 variant tracks
            if (rv$trackCount >= 4) {
                showNotification("Maximum of 4 variant tracks allowed.", type = "message")
                return()
            }
            rv$trackCount <- rv$trackCount + 1
            idx <- rv$trackCount
            track_ns <- paste0("_", idx)
            
            insertUI(
                selector = paste0("#", ns("variantTracksContainer")),
                where = "beforeEnd",
                ui = wellPanel(
                    id = paste0("variantPanel", track_ns),
                    style = "flex: 0 0 280px; margin: 5px;", # Slightly smaller width for better fit
                    h4(paste("Variant Track", idx)),
                    selectInput(session$ns(paste0("lineage", track_ns)), "Lineage:", 
                               choices = exp_line_factor, selected = "MT-2_1"),
                    selectInput(session$ns(paste0("passage", track_ns)), "Passage:", 
                               choices = as.character(seq(10, 500, 10)), selected = "100"),
                    sliderInput(session$ns(paste0("af_range", track_ns)), "Allele Frequency Range:", 
                               min = 0, max = 1, value = c(0.01, 1), step = 0.01),
                    actionButton(session$ns(paste0("loadVariants", track_ns)), "Load Variants")
                )
            )
            
            observeEvent(input[[paste0("loadVariants", track_ns)]], {
                # Defensive check - debug info
                cat("Load Variants clicked for track", idx, "\n")
                
                vcf_data <- readVcf(vcf_file, genome_name)
                info_data <- info(vcf_data)
                
                af <- as.numeric(info_data$AF)
                line <- as.character(info_data$LINE)
                passage <- as.integer(info_data$PASSAGE)
                
                # Use input directly, NOT namespaced again here
                selected <- which(
                    line == line_conversion_tbl[[input[[paste0("lineage", track_ns)]]]] &
                    passage == as.integer(input[[paste0("passage", track_ns)]]) &
                    af >= input[[paste0("af_range", track_ns)]][1] &
                    af <= input[[paste0("af_range", track_ns)]][2]
                )
                
                filtered_vcf <- vcf_data[selected]
                
                if (length(filtered_vcf) == 0) {
                    showNotification("No variants found for selected filters", type = "warning")
                    return()
                }
                
                loadVcfTrack(
                    session = session,
                    id = ns("igv_browser"),
                    trackName = paste0("Variant Track ", idx),
                    vcfData = filtered_vcf
                )
            }, ignoreInit = TRUE)
        })

        # Remove all user-added tracks and UI
        observeEvent(input$removeUserTracks, {
            removeUserAddedTracks(session, id = ns("igv_browser"))
            rv$trackCount <- 0
            removeUI(selector = paste0("#", ns("variantTracksContainer"), " > *"))
        })
    })



