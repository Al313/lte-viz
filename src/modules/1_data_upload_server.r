

# Server module for tab1

tab1Server <- function(id) {
    moduleServer(id, function(input, output, session) {
    


        observeEvent(input$DownloadData, {
            showNotification("Selected data is downloading ...", type = "message")
        })
        
        
    })
}

