

# Server module for tab1

tab1Server <- function(id) {
    moduleServer(id, function(input, output, session) {
    

        # Create genome options
        genomeOptionsPreload <- eventReactive(input$preLoadData, {

            # Use input data for HIV-1 genome
            genome_name <- "HIV-1 (NL4_3)"
            fasta_file <- file.path("data/igv-input/plasmid/reference.fasta")
            annotation_file <- file.path("data/igv-input/plasmid/annotation.gff3")
            vcf_file <- file.path("data/igv-input/plasmid/filtered_variants.vcf.gz")
        
            parseAndValidateGenomeSpec(
                genomeName = genome_name,
                initialLocus = "AF324493.2:600-700",
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
                initialLocus = "AF324493.2:600-700",
                stockGenome = FALSE,
                dataMode = "localFiles",
                fasta = input$fastaPath,
                fastaIndex = paste0(input$fastaPath, ".fai")
            )
        })

        # observeEvent(genomeOptionsPreload(), {
        #     dataUploaded(TRUE)
        # })
        
        # observeEvent(genomeOptionsCustom(), {
        #     dataUploaded(TRUE)
        # })
        
        # Conditional rendering based on input$dataSourceChoice
        output$uploadMessage <- renderUI({
            if (input$dataSourceChoice == "LTEE HIV-1" && input$preLoadData > 0) {
                req(genomeOptionsPreload())
                wellPanel(
                    style = "background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; border-radius: 5px;",
                    tags$h4("✅ Data upload was successful."),
                    tags$p("Please proceed to other tabs for exploring the data.")
                )
                
            } else if (input$dataSourceChoice == "Third-party data" && input$loadFiles > 0) {
                req(genomeOptionsCustom())
                wellPanel(
                    style = "background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; border-radius: 5px;",
                    tags$h4("✅ Your files were loaded successfully."),
                    tags$p("Please proceed to other tabs for exploring the data.")
                )
                
            }
        })
    })
}

