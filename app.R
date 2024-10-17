library(shiny)
library(shinydashboard)

# 2502458 Mustafa Uğur Yalçın
# 2502169 Melih Can Kanmaz
# 2442051 Tevfik Oğuz

ui <- navbarPage(
  title = "COVID-19 Data Dashboard",
  
  tabPanel("Description",
           fluidPage(
             source("info.R", local = TRUE)$value
           )
  ),
  
  tabPanel("Map",
           fluidPage(
             source("map.R", local = TRUE)$value
           )
  ),
  tabPanel("Regression Model",
           fluidPage(
             source("Regression_model.R", local = TRUE)$value
           )
  ),
  tabPanel("Time Series Model",
           fluidPage(
             source("tsmodels.R", local = TRUE)$value
           )
  ),
  position = "static",
  tags$style(".tab-pane iframe{ height: 100vh; }")
)


server <- function(input, output) {
  
}

shinyApp(ui = ui, server = server)