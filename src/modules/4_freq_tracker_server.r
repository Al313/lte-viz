


# Define server function  
tab4Server <- function(id, mutation_data) {
    moduleServer(id, function(input, output, session) {

        df <- mutation_data
        df$mut_info_line <- paste0(df$mut_info, "_", df$exp_line)
        

        # Reactive filtered data
        filter_data <- reactive({
            req(input$mutCase1, input$lineage)  # Ensure inputs are available
            df[df$mut_info %in% c(input$mutCase1, input$mutCase2) & df$exp_line %in% input$lineage, ]
        })

        # Frequency trajectory plot (plotly)
        output$mutation_plot <- renderPlotly({
            req(input$freq_mode == "Frequency trajectory")
            df <- filter_data()

            # Check if data frame is empty
            validate(
                need(nrow(df) > 0, "No records found for the selected filters.")
            )

            df$passage <- as.numeric(as.character(df$passage))

            fig <- ggplot(df, aes(x = passage, y = allele_freq, color = exp_line, linetype = mut_info, group = mut_info_line)) +
                geom_line(linewidth = 1.5) +
                scale_alpha_manual(values = c(0.1, 1)) +
                scale_x_continuous(breaks = seq(10, 500, 10), limits = c(10, 500)) +
                scale_y_log10(
                    breaks = c(1, 0.5, 0.2, 0.1, 0.05, 0.02, 0.01),
                    labels = scales::label_number(),
                    limits = c(-1, 1)
                ) +
                labs(
                y = "Variant Frequency (log10 scale) \n",
                x = "\n Transfer",
                color = "Lineage / Mutation\n",
                linetype = ""
                ) +
                scale_color_manual(labels = c("MT-2_1","MT-2_2","MT-4_1","MT-4_2"), values = c("#ff00ff", "#ff2400", "#6600cc", "#0000ff")) +
                guides(color = guide_legend(order = 1), linetype = guide_legend(order = 1)) +  # same order merges them visually
                theme_bw() +
                theme(axis.text.x = element_text(angle = 90))

            ggplotly(fig)

        })

        # Frequency distribution animation (GIF)
        output$mutation_gif <- renderImage({
            req(input$freq_mode == "Frequency distribution")
            
            list(
                src = "src/misc/www/freq_distribution.gif",  # path to your saved gif
                contentType = "image/gif",
                width = "75%"                       # can also use a numeric pixel value
            )
        }, deleteFile = FALSE)

    })
}




