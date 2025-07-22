# Server module for tab3
tab3Server <- function(id) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns  # Namespace function for this module
        
        rv <- reactiveValues(
            trackCount = 0,
            observers = list()  # Store observer references for cleanup
        )

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
            
            # Create input IDs without namespace (they'll be namespaced when created)
            lineage_id <- paste0("lineage", track_ns)
            passage_id <- paste0("passage", track_ns)
            af_range_id <- paste0("af_range", track_ns)
            load_button_id <- paste0("loadVariants", track_ns)
            
            insertUI(
                selector = paste0("#", ns("variantTracksContainer")),
                where = "beforeEnd",
                ui = wellPanel(
                    id = paste0("variantPanel", track_ns),
                    style = "flex: 0 0 280px; margin: 5px;",
                    h4(paste("Variant Track", idx)),
                    selectInput(ns(lineage_id), "Lineage:", 
                            choices = c("MT-2_1","MT-2_2","MT-4_1","MT-4_2"), selected = "MT-2_1"),
                    selectInput(ns(passage_id), "Passage:", 
                            choices = as.character(seq(10, 500, 10)), selected = "100"),
                    sliderInput(ns(af_range_id), "Allele Frequency Range:", 
                            min = 0, max = 1, value = c(0.01, 1), step = 0.01),
                    actionButton(ns(load_button_id), "Load Variants")
                )
            )
            
            # Create and store observer for this track
            observer_key <- paste0("track_", idx)
            
            rv$observers[[observer_key]] <- observeEvent(input[[load_button_id]], {
                # Capture current values immediately
                current_idx <- idx
                current_lineage <- input[[lineage_id]]
                current_passage <- input[[passage_id]]
                current_af_range <- input[[af_range_id]]
                
                cat("Loading variants for track", current_idx, "\n")
                cat("Lineage:", current_lineage, "Passage:", current_passage, "\n")
                
                # Validate inputs before proceeding
                if (is.null(current_lineage) || is.null(current_passage) || is.null(current_af_range)) {
                    showNotification("Please ensure all inputs are selected", type = "warning")
                    return()
                }
                
                tryCatch({
                    # Show loading notification
                    loading_id <- showNotification("Loading variants...", 
                                                 type = "message", 
                                                 duration = NULL)
                    on.exit(removeNotification(loading_id), add = TRUE)
                    
                    # Load VCF data
                    if (!file.exists(vcf_file)) {
                        stop("VCF file not found: ", vcf_file)
                    }
                    
                    vcf_data <- VariantAnnotation::readVcf(vcf_file, genome_name)
                    info_data <- VariantAnnotation::info(vcf_data)

                    # Validate VCF data structure
                    if (!"AF" %in% names(info_data) || 
                        !"LINE" %in% names(info_data) || 
                        !"PASSAGE" %in% names(info_data)) {
                        stop("Required VCF INFO fields (AF, LINE, PASSAGE) not found")
                    }

                    af <- as.numeric(info_data$AF)
                    line <- as.character(info_data$LINE)
                    passage <- as.integer(info_data$PASSAGE)
                    
                    # Validate conversion table
                    if (!current_lineage %in% names(line_conversion_tbl)) {
                        stop("Invalid lineage selection: ", current_lineage)
                    }
                    
                    # Filter variants
                    selected_line <- line_conversion_tbl[[current_lineage]]
                    selected_passage <- as.integer(current_passage)
                    
                    selected <- which(
                        !is.na(line) & !is.na(passage) & !is.na(af) &
                        line == selected_line &
                        passage == selected_passage &
                        af >= current_af_range[1] &
                        af <= current_af_range[2]
                    )
                    
                    cat("Found", length(selected), "matching variants\n")
                    
                    if (length(selected) == 0) {
                        showNotification("No variants found for selected filters", type = "warning")
                        return()
                    }
                    
                    filtered_vcf <- vcf_data[selected]
                    
                    # Load track with unique name
                    track_name <- paste0("Variants_", current_lineage, "_P", current_passage, "_T", current_idx)
                    
                    loadVcfTrack(
                        session = session,
                        id = ns("igv_browser"),
                        trackName = track_name,
                        vcfData = filtered_vcf
                    )
                    
                    showNotification(
                        paste("Loaded", length(filtered_vcf), "variants for track", current_idx), 
                        type = "message"
                    )
                    
                }, error = function(e) {
                    error_msg <- paste("Error loading variants for track", current_idx, ":", e$message)
                    cat(error_msg, "\n")
                    showNotification(error_msg, type = "error")
                })
            }, ignoreInit = TRUE)
        })

        # Remove all user-added tracks and UI
        observeEvent(input$removeUserTracks, {
            # Clean up observers
            for (obs in rv$observers) {
                if (!is.null(obs)) {
                    obs$destroy()
                }
            }
            rv$observers <- list()
            
            # Remove tracks and reset counter
            removeUserAddedTracks(session, id = ns("igv_browser"))
            rv$trackCount <- 0
            removeUI(selector = paste0("#", ns("variantTracksContainer"), " > *"))
        })
        
        # Clean up observers when session ends
        session$onSessionEnded(function() {
            for (obs in rv$observers) {
                if (!is.null(obs)) {
                    obs$destroy()
                }
            }
        })
    })
}