####################################
# Data Professor                   #
# http://youtube.com/dataprofessor #
# http://github.com/dataprofessor  #
####################################

# Modified from https://shiny.rstudio.com/tutorial/written-tutorial/lesson1/

library(shiny)
library(shinythemes)
library(ggplot2)
library(plotly)
data(airquality)

# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Ozone level!"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Slider for the number of bins ----
      sliderInput(inputId = "bins",
                  label = "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Histogram ----
      plotlyOutput(outputId = "distPlot")
      
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  

  output$distPlot <- renderPlotly({
    
    x    <- airquality$Ozone
    x    <- na.omit(x)
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
       # Use ggplot2 to build the histogram
    p <- ggplot(data.frame(Ozone = x), aes(x = Ozone)) +
      geom_histogram(bins = input$bins, fill = "#75AADB", color = "black") +
      labs(x = "Ozone level", title = "Histogram of Ozone level")
    
    # Convert ggplot object to plotly for interactivity
    ggplotly(p)
    
  })
  
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
