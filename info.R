#importing library
library(shiny)
#ui section
ui <- fluidPage(
  tags$div(
    style = "padding: 20px;",
    tags$h1("COVID INSIGHTS",style = "color: #0072B2;"),
    tags$h2("Purpose of Our Project",style = "color: #0072B2;"),
    tags$p("Our purpose with the project is to conduct a comprehensive analysis on the pandemic that the world has experienced. The aim of our research is to understand the intricate dynamics of this pandemic specifically within the context of Europe, trying to understand how European countries have dealt with the pandemic.", style = "font-size: 18px;"),
    tags$hr(),
    tags$h2("Brief Explanation",style = "color: #0072B2;"),
    tags$p("The Covid Insights app provides users with an interactive experience to study and examine COVID-19 pandemic statistics for European nations. Users of the app can visually explore the data at the country level thanks to a map that is included. Regression and time series models are also available in the app to enable more in-depth research and insights into COVID-19 trends and patterns.",style = "font-size: 18px;"),
    tags$hr(),
    tags$h2("Contributors",style = "color: #0072B2;"),
    tags$p("Melih Can Kanmaz 2502169",style = "font-size: 18px;"),
    tags$p("Mustafa Uğur Yalçın 2502458",style = "font-size: 18px;"),
    tags$p("Tevfik Oğuz 2442051",style = "font-size: 18px;"),
    tags$hr(),
    tags$h2("Analysis",style = "color: #0072B2;"),
    tags$p("In our analysis, we have tried to use different statistical analysis methods such as linear models, time series analysis models. Also, to show our findings about our analysis, we used different visualization techniques to explain our results.",style = "font-size: 18px;"),
    tags$hr(),
    tags$h2("Results",style = "color: #0072B2;"),
    tags$p("We tried to find the relation between each variable in our dataset with using time series analysis to forecast past and the future of those variables.",style = "font-size: 18px;"),
    tags$hr(),
    tags$h2("References",style = "color: #0072B2;"),
    tags$a("Mathieu, E. (2020, March 5). Coronavirus Pandemic (COVID-19). Our World in Data. https://ourworldindata.org/coronavirus",href="https://ourworldindata.org/coronavirus",style = "font-size: 18px;"),
    br(),
    tags$a("Owid. (n.d.). covid-19-data/public/data at master · owid/covid-19-data. GitHub. https://github.com/owid/covid-19-data/tree/master/public/data",href="https://github.com/owid/covid-19-data/tree/master/public/data",style = "font-size: 18px;"),
    br(),
    tags$a("Shiny Dashboard. (n.d.). https://rstudio.github.io/shinydashboard/",href="https://rstudio.github.io/shinydashboard/",style = "font-size: 18px;"),
    br(),
    tags$a("Shiny docs. (n.d.). Shiny. https://shiny.posit.co/r/reference/shiny/1.7.4/",href="https://shiny.posit.co/r/reference/shiny/1.7.4/",style = "font-size: 18px;"),
  )
)
#run
shinyApp(ui = ui, server = function(input, output) {})

