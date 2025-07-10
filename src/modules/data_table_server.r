
# Define server function  
tab1Server <- function(id) {
    moduleServer(id, function(input, output, session) {

        observe({
            # If "All" is selected in features, update to all features (except if already fully selected)
            if ("All" %in% input$feature && !all(feature_factor %in% input$feature)) {
            updateCheckboxGroupInput(session, "feature",
                selected = c("All", feature_factor))
            }

            # If "All" is deselected manually in features, remove it from selected
            if (!"All" %in% input$feature && all(feature_factor %in% input$feature)) {
            updateCheckboxGroupInput(session, "feature",
                selected = "gag")
            }

            # If "All" is selected in trans_impact, update to all impacts (except if already fully selected)
            if ("Any" %in% input$trans_impact && !all(names(impact_factor) %in% input$trans_impact)) {
            updateCheckboxGroupInput(session, "trans_impact",
                selected = c("Any", names(impact_factor)))
            }

            # If "Any" is deselected manually in trans_impact, remove it from selected
            if (!"Any" %in% input$trans_impact && all(names(impact_factor[-1]) %in% input$trans_impact)) {
            updateCheckboxGroupInput(session, "trans_impact",
                selected = "Untranslated")
            }
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

            # Remove "All" from the selection if present
            selected_features <- setdiff(input$feature, "All")
            selected_trans_impact <- setdiff(input$trans_impact, "All")
            
            subset <- variant_data[
            variant_data$exp_line %in% input$lineage &
            variant_data$passage == input$passage &
            variant_data$allele_freq >= input$af_range[1] &
            variant_data$allele_freq <= input$af_range[2] &
            variant_data$effect_simplified %in% impact_factor[selected_trans_impact], ]

            # Conditional filtering based on mode
            if (input$filter_mode == "Position") {
                subset <- subset[subset$genomic_pos %in% pos_range, ]
            } else if (input$filter_mode == "Feature") {
                subset <- subset[subset$feature %in% selected_features, ]
            } 
            
            datatable(subset, options = list(pageLength = 10))
        })
    })
} # server
