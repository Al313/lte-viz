# define functions

multiply_nested_list <- function(nested_list, multiplier) {
  lapply(nested_list, function(inner) {
    lapply(inner, function(x) x * multiplier)
  })
}


custom_plot_theme <- function(application = "publication", scale = 1) {
    size_set <- list(
    publication = list(
        title = 0,
        axis_title = 20,
        axis_text = 10,
        strip_text = 20,
        legend_title = 15,
        legend_text = 10
    ),
    presentation = list(
        title = 50,
        axis_title = 40,
        axis_text = 30,
        strip_text = 40,
        legend_title = 40,
        legend_text = 30
    ))

    size_set <- multiply_nested_list(size_set, scale)
    
    
    theme_bw() +
    theme(
        plot.title = element_text(size = size_set[[application]]["title"], hjust = 0.5),
        axis.title = element_text(size = size_set[[application]]["axis_title"]),
        axis.text.x = element_text(size = size_set[[application]]["axis_text"], color = "black", angle = 90),
        axis.text.y = element_text(size = size_set[[application]]["axis_text"], color = "black"),
        strip.text.x = element_text(size = 50, angle=0),
        legend.title = element_text(size = size_set[[application]]["legend_title"]),
        legend.text = element_text(size = size_set[[application]]["legend_text"])
    )
}




# Define server function  
tab3Server <- function(id) {
    moduleServer(id, function(input, output, session) {


        # Reactive filtered data
        filtered_data <- reactive({
            req(input$mutCase, input$lineage)  # Ensure inputs are available
            df <- variant_data
            df$mut_info_line <- paste0(df$mut_info, "_", df$exp_line)
            df[df$mut_info %in% input$mutCase & df$exp_line %in% input$lineage, ]
        })

        # Render plot
        output$variant_plot <- renderPlotly({
        df <- filtered_data()

        fig <- ggplot(df, aes(x = passage, y = log10(allele_freq), color = exp_line, group = mut_info_line)) +
            geom_line(linewidth = 2) +
            scale_alpha_manual(values = c(0.1, 1)) +
            scale_y_continuous(breaks = c(0, -1, -2, -3), labels = c("1", "0.1", "0.01", "0.001")) +
            labs(
            y = "Frequency \n",
            x = "\n Transfer",
            color = "Lineage\n"
            ) +
            scale_color_manual(labels = exp_line_factor, values = line_col_palette) +
            custom_plot_theme(application = "publication")

        ggplotly(fig)

        })
    })
}




