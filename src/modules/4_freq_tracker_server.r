



# Define server function  
tab4Server <- function(id, variant_data) {
    moduleServer(id, function(input, output, session) {

        df <- variant_data
        df$mut_info_line <- paste0(df$mut_info, "_", df$exp_line)

        # Reactive filtered data
        filter_data <- reactive({
            req(input$mutCase, input$lineage)  # Ensure inputs are available
            df[df$mut_info %in% input$mutCase & df$exp_line %in% input$lineage, ]
        })

        # Render plot
        output$variant_plot <- renderPlotly({
        df <- filter_data()

        fig <- ggplot(df, aes(x = passage, y = log10(allele_freq), color = exp_line, group = mut_info_line)) +
            geom_line(linewidth = 2) +
            scale_alpha_manual(values = c(0.1, 1)) +
            scale_y_continuous(breaks = c(0, -1, -2, -3), labels = c("1", "0.1", "0.01", "0.001")) +
            labs(
            y = "Frequency \n",
            x = "\n Transfer",
            color = "Lineage\n"
            ) +
            scale_color_manual(labels = c("MT-2_1","MT-2_2","MT-4_1","MT-4_2"), values = c("#ff00ff", "#ff2400", "#6600cc", "#0000ff")) +
            theme_bw()

        ggplotly(fig)

        })
    })
}




