

# Define server function  
tab2Server <- function(id, variant_data, impact_factor) {
    moduleServer(id, function(input, output, session) {

        ns <- session$ns

        observe({
            
            if ("Select All" %in% input$trans_impact){
                selected_impacts <- c("Untranslated", "Synonymous", "Non-synonymous")
            } else {
                selected_impacts <- input$trans_impact
            }
            
            updateSelectInput(session, "trans_impact", selected = selected_impacts)
            

        })

        observe({
            updateCheckboxGroupInput(session, "feature", choices = c("5R","5UTR","5LTRLS","gag","pol","vif","vpr","tat","rev","vpu","env","nef","3UTR","3R"),
                selected = if(input$feature_all_or_none) {
                    c("5R","5UTR","5LTRLS","gag","pol","vif","vpr","tat","rev","vpu","env","nef","3UTR","3R")
                } else {
                    c()
            })
        })


        output$DT_out <- renderDT({
            
            pos_input <- gsub(" ", "", input$position)
            pos_range <- tryCatch({
            if (grepl("-", pos_input)) {
                bounds <- strsplit(pos_input, "-")[[1]]
                start <- as.numeric(bounds[1])
                end <- as.numeric(bounds[2])
                
                if (start > end) {
                showNotification("Start position is greater than end position. Please enter a valid range (e.g., 9510-9522).", type = "error")
                return(numeric(0))  # return empty so no match is made
                } else {
                seq(start, end)
                }
            } else {
                as.numeric(pos_input)
            }
            }, error = function(e) {
                showNotification("Invalid position format. Use a number or a range like 102-202.", type = "error")
                numeric(0)
            })

            
            subset_data <- variant_data[
                variant_data$exp_line %in% input$lineage &
                variant_data$passage == input$passage &
                variant_data$allele_freq >= input$af_range[1] &
                variant_data$allele_freq <= input$af_range[2] &
                variant_data$effect_simplified %in% impact_factor[input$trans_impact], ]

            # Conditional filtering based on mode
            if (input$filter_mode == "Position") {
                subset_data <- subset_data[subset_data$genomic_pos %in% pos_range, ]
            } else if (input$filter_mode == "Feature") {
                subset_data <- subset_data[subset_data$feature %in% input$feature, ]
            } 
            
            datatable(subset_data, options = list(pageLength = 10))
        })

        gc()
    })
} # server
