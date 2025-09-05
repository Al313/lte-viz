
tab5UI <- function(id) {
    ns <- NS(id)
    tabPanel("Publication Figures",
        tabsetPanel(

            # ==== FIGURE 1 ====
            tabPanel("Figure 1 _ Fitness Effects",
                sidebarLayout(
                    sidebarPanel(
                    tags$h3("User Inputs Figure 1"),
                    checkboxGroupInput(ns("lineage1"), 
                        label = "Select lineage(s):",
                        choices = c("MT-2_1","MT-2_2","MT-4_1","MT-4_2"),
                        selected = "MT-2_1"
                    ),
                    checkboxGroupInput(ns("mut1"), 
                        label = "Triple/Quadruple mutation:",
                        choices = c("566_G_A","678_G_A","2058_G_A","5127_G_A",
                                    "7854_A_G","7963_G_A","8161_G_A","8667_C_T",
                                    "9412_G_A","9416_T_C","9439_G_A","9522_C_T","9528_T_G")
                    ),
                    checkboxInput(ns("mutation_all_or_none"), label = "All/None", value = TRUE)
                    ),
                    mainPanel(
                        plotlyOutput(ns("plot1"), width = "100%", height = "700px")
                    )
                )
            ),

            # ==== FIGURE 2 ====
            tabPanel("Figure 2",
                sidebarLayout(
                    sidebarPanel(
                        tags$h3("User Inputs Figure 2"),
                        
                    ),
                    mainPanel(
                        plotlyOutput(ns("plot2"), width = "100%", height = "700px")
                    )
                )
            ),

            # ==== FIGURE 3 ====
            tabPanel("Figure 3",
                sidebarLayout(
                    sidebarPanel(
                        tags$h3("User Inputs Figure 3"),
                        
                    ),
                    mainPanel(
                        plotlyOutput(ns("plot3"), width = "100%", height = "700px")
                    )
                )
            ),

            # ==== FIGURE 4 ====
            tabPanel("Figure 4",
                sidebarLayout(
                    sidebarPanel(
                        tags$h3("User Inputs Figure 4"),
                        
                    ),
                    mainPanel(
                        plotlyOutput(ns("plot4"), width = "100%", height = "700px")
                    )
                )
            ),

            # ==== FIGURE 4 ====
            tabPanel("Figure 5",
                sidebarLayout(
                    sidebarPanel(
                        tags$h3("User Inputs Figure 5"),
                        
                    ),
                    mainPanel(
                        plotlyOutput(ns("plot5"), width = "100%", height = "700px")
                    )
                )
            )
        )
    )
}
