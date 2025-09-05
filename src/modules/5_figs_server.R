



# Define server function  
tab5Server <- function(id, mutation_data) {
    moduleServer(id, function(input, output, session) {

        observe({
            updateCheckboxGroupInput(session, "mut1", choices = c("566_G_A","678_G_A","2058_G_A","5127_G_A",
                                    "7854_A_G","7963_G_A","8161_G_A","8667_C_T",
                                    "9412_G_A","9416_T_C","9439_G_A","9522_C_T","9528_T_G"),
                selected = if(input$mutation_all_or_none) {
                    c("566_G_A","678_G_A","2058_G_A","5127_G_A",
                                    "7854_A_G","7963_G_A","8161_G_A","8667_C_T",
                                    "9412_G_A","9416_T_C","9439_G_A","9522_C_T","9528_T_G")
                } else {
                    c()
            })
        })

        # Frequency trajectory plot (plotly)
        output$plot1 <- renderPlotly({
            
            init_fit <- readRDS(file = "data/initial_relative_fitness_triple_quadruple.rds")
            init_fit_filtered <- init_fit[init_fit$mut_info %in% input$mut1 & init_fit$exp_line %in% input$lineage1, ]

            fig <- init_fit_filtered %>%
                ggplot(aes(x = relative_order, y = log2(init_rel_fit), color = exp_line)) +
                geom_point(aes(), size = 3) +
                geom_smooth(aes(group = exp_line), method = "lm", se = FALSE) +
                labs(title = "", y = "log2(initial relative fitness)\n", x = "Relative order \n(No. of prior triple/quadruple-occurrence)", color = "Lineage", linetype = "Lineage") +
                scale_x_continuous(breaks = seq(0,12, 1), limits = c(0,12))+
                scale_y_continuous(breaks = seq(-8,-1, 1), limits = c(-8,0))+
                scale_color_manual(
                    values = c(
                        "MT-2_1" = "#ff00ff",
                        "MT-2_2" = "#ff2400",
                        "MT-4_1" = "#6600cc",
                        "MT-4_2" = "#0000ff"
                    )
                )+
                guides(color = guide_legend(order = 1), linetype = guide_legend(order = 1)) +  # same order merges them visually
                theme_bw() +
                theme(axis.text.x = element_text(angle = 90))

            ggplotly(fig) %>%
                layout(legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 1.2))

            
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

        gc()

    })
}





