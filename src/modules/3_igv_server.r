

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
tab3Server <- function(id, options, annotation_file, module_data) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns  # Namespace function for this module
        
        # Create reactive values to cache VCF data
        vcf_cache <- reactiveValues(
            vcf_data = NULL,
            info_data = NULL,
            loaded = FALSE
        )
        
        # Function to load VCF data only when needed
        load_vcf_data <- function() {
            if (!vcf_cache$loaded) {
                vcf_cache$vcf_data <- VariantAnnotation::readVcf(vcf_file, genome_name)
                vcf_cache$info_data <- VariantAnnotation::info(vcf_cache$vcf_data)
                vcf_cache$loaded <- TRUE
            }
            return(list(vcf_data = vcf_cache$vcf_data, info_data = vcf_cache$info_data))
        }

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
                deleteTracksOfSameName = TRUE
            )
        })
        
        observeEvent(input$addMutationTrack, {
            # limit to 4 mutation tracks
            if (rv$trackCount >= 4) {
                showNotification("Maximum of 4 mutation tracks allowed.", type = "message")
                return()
            }
            rv$trackCount <- rv$trackCount + 1
            idx <- rv$trackCount
            track_ns <- paste0("_", idx)
            
            insertUI(
                selector = paste0("#", ns("mutationTracksContainer")),
                where = "beforeEnd",
                ui = wellPanel(
                    id = paste0("mutationPanel", track_ns),
                    style = "flex: 0 0 280px; margin: 5px;", # Slightly smaller width for better fit
                    h4(paste("Mutation Track", idx)),
                    selectInput(session$ns(paste0("lineage", track_ns)), "Lineage:", 
                            choices = c("MT-2_1","MT-2_2","MT-4_1","MT-4_2"), selected = "MT-2_1"),
                    selectInput(session$ns(paste0("passage", track_ns)), "Passage:", 
                            choices = as.character(seq(10, 500, 10)), selected = "100"),
                    sliderInput(session$ns(paste0("af_range", track_ns)), "Variant Frequency Range:", 
                            min = 0, max = 1, value = c(0.01, 1), step = 0.01),
                    actionButton(session$ns(paste0("loadMutations", track_ns)), "Load Mutations")
                )
            )
            
            
            observeEvent(input[[paste0("loadMutations", track_ns)]], {
                
                # Disable the button immediately
                shinyjs::disable(paste0("loadMutations", track_ns))
                
                # Show loading notification
                loading_id <- showNotification("Loading mutations... Please wait.", type = "message", duration = NULL)
                

                # Load VCF data only when needed (cached after first load)
                vcf_info <- load_vcf_data()
                vcf_data <- vcf_info$vcf_data
                info_data <- vcf_info$info_data
                
                # Use input directly, NOT namespaced again here
                selected <- which(
                    as.character(info_data$LINE) == line_conversion_tbl[[input[[paste0("lineage", track_ns)]]]] &
                    as.integer(info_data$PASSAGE) == as.integer(input[[paste0("passage", track_ns)]]) &
                    as.numeric(info_data$AF) >= input[[paste0("af_range", track_ns)]][1] &
                    as.numeric(info_data$AF) <= input[[paste0("af_range", track_ns)]][2]
                )
                
                filtered_vcf <- vcf_data[selected]
                
                rm(vcf_data)
                rm(info_data)
                rm(vcf_info)
                gc()

                if (length(filtered_vcf) == 0) {
                    showNotification("No mutations found for selected filters", type = "warning")
                    return()
                }
                
                loadVcfTrack(
                    session = session,
                    id = ns("igv_browser"),
                    trackName = paste0("Mutation Track ", idx),
                    vcfData = filtered_vcf
                )

                # Remove loading message
                removeNotification(loading_id)

                # re-enable after load
                shinyjs::enable(paste0("loadMutations", track_ns))
                
            }, ignoreInit = TRUE)         
        })

        # Remove all user-added tracks and UI
        observeEvent(input$removeUserTracks, {
            removeUserAddedTracks(session, id = ns("igv_browser"))
            rv$trackCount <- 0
            removeUI(selector = paste0("#", ns("mutationTracksContainer"), " > *"), multiple = TRUE)
        })
    })
}


