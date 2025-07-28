


# Define server function  
tab4Server <- function(id, mutation_data) {
    moduleServer(id, function(input, output, session) {

        df <- mutation_data
        df$mut_info_line <- paste0(df$mut_info, "_", df$exp_line)

        # Reactive filtered data
        filter_data <- reactive({
            req(input$mutCase, input$lineage)  # Ensure inputs are available
            df[df$mut_info %in% input$mutCase & df$exp_line %in% input$lineage, ]
        })

        # Render plot
        output$mutation_plot <- renderPlotly({
        df <- filter_data()
        df$passage <- as.numeric(as.character(df$passage))

        fig <- ggplot(df, aes(x = passage, y = allele_freq, color = exp_line, group = mut_info_line)) +
            geom_line(linewidth = 2) +
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
            color = "Lineage\n"
            ) +
            scale_color_manual(labels = c("MT-2_1","MT-2_2","MT-4_1","MT-4_2"), values = c("#ff00ff", "#ff2400", "#6600cc", "#0000ff")) +
            theme_bw() +
            theme(axis.text.x = element_text(angle = 90))

        ggplotly(fig)

        })

        gc()
    })
}




