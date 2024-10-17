#importing libraries
library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)
#importing data
data <- read.csv("owid-covid-data.csv", header = TRUE)
data_eu_death <- subset(data, continent == "Europe")
data_eu_death <- data_eu_death[, c(3, 4, 8, 11, 12, 15, 17, 19, 21, 23, 25, 29, 32, 33, 35, 42, 48, 61, 62)]
data_eu_death <- na.omit(data_eu_death)
#setting ui
ui <- fluidPage(
  titlePanel("COVID-19 Statistics in Europe"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(inputId = "variables",
                         label = "Select variables:",
                         choices = c("total_cases_per_million",
                                     "new_cases_per_million", "new_deaths_per_million",
                                     "reproduction_rate", "icu_patients_per_million",
                                     "hosp_patients_per_million",
                                     "weekly_icu_admissions_per_million",
                                     "weekly_hosp_admissions_per_million",
                                     "new_tests_per_thousand",
                                     "positive_rate", "tests_per_case",
                                     "total_vaccinations",
                                     "people_vaccinated_per_hundred",
                                     "stringency_index", "life_expectancy",
                                     "human_development_index"),
                         selected = c("total_cases_per_million", "new_deaths_per_million", "hosp_patients_per_million", "total_vaccinations")),
      br(),
      actionButton(inputId = "toggle_variables", label = "Toggle All"),
      br(),
      helpText("Select the variables to include in the linear model."),
      checkboxGroupInput(inputId = "countries",
                         label = "Select countries:",
                         choices = c("Cyprus", "Czechia", "Estonia", "France", "Ireland",
                                    "Italy", "Luxembourg", "Netherlands",
                                     "Slovakia", "Slovenia", "Spain"),
                         selected = c("France", "Spain")),
      
      br(),
      actionButton(inputId = "toggle_countries", label = "Toggle All")
    ),
    mainPanel(
      plotlyOutput(outputId = "regression_plot"),
      h4("R-squared:"),
      verbatimTextOutput(outputId = "rsquared_text")
    )
  )
)
server <- function(input, output, session) {
  filtered_data <- reactive({
    data_eu_death %>%
      filter(location %in% input$countries) %>%
      na.omit()
  })
  #fitting a model
  model <- reactive({
    if (is.null(input$variables) || length(input$variables) == 0) {
      return(NULL)
    }
    variables <- input$variables[!input$variables %in% c("date", "location")]
    formula <- as.formula(paste("total_deaths ~", paste(variables, collapse = " + ")))
    lm(formula, data = filtered_data())
  })
  rsquared <- reactive({
    if (!is.null(model())) {
      summary(model())$r.squared
    }
  })
  observeEvent(input$toggle_variables, {
    if (length(input$variables) + 1 < length(setdiff(names(data_eu_death), c("date", "location")))) {

      updateCheckboxGroupInput(session, "variables", selected = setdiff(names(data_eu_death), c("date", "location")))
    } else {

      updateCheckboxGroupInput(session, "variables", selected = character(0))
    }
  })
  observeEvent(input$toggle_countries, {
    if (length(input$countries) < length(unique(data_eu_death$location))) {
      updateCheckboxGroupInput(session, "countries", choices = unique(data_eu_death$location), selected = unique(data_eu_death$location))
    } else {
      updateCheckboxGroupInput(session, "countries", choices = unique(data_eu_death$location), selected = character(0))
    }
  })
#show regression graph
  output$regression_plot <- renderPlotly({
    if (!is.null(model())) {
      plot_obj <- ggplot(filtered_data(), aes_string(x = paste(input$variables, collapse = "+"), y = "total_deaths" , color = "location")) +
        geom_point(size = 3, alpha = 0.8) +
        geom_smooth(method = "lm", se = FALSE, linetype = "dashed") +
        labs(x = "Selected Variables", y = "Total Deaths") +
        theme_minimal() +
        theme(plot.title = element_text(size = 18, face = "bold"),
              axis.title = element_text(size = 14),
              axis.text = element_text(size = 12),
              legend.position = "bottom")
      

      plotly_obj <- ggplotly(plot_obj, tooltip = "y")
      
      plotly_obj
    }
  })
  #Rsquared
  output$rsquared_text <- renderText({
    if (!is.null(model())) {
      paste0("R-squared: ", format(rsquared(), digits = 4))
    }
  })
  #show selected values
  output$selected_values <- renderPrint({
    point <- nearPoints(filtered_data(), input$regression_plot_hover, threshold = 10, maxpoints = 1, addDist = TRUE)
    if (!is.null(point)) {
      selected_vars <- input$variables
      selected_vars <- selected_vars[selected_vars != "total_deaths"]
      selected_values <- point[, selected_vars]
      print(selected_values)
    }
  })
  
}
#Run
shinyApp(ui = ui, server = server)
