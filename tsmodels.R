library(shiny)
library(forecast)
library(tseries)
library(lubridate)

# Importing data from the csv file
data <- read.csv("owid-covid-data.csv")

# Interface
ui <- fluidPage(
  titlePanel("COVID-19 Cases"),
  sidebarLayout(
    sidebarPanel(
      selectInput("country", "Select a country:",
        choices = unique(data[data$continent == "Europe" & !data$location %in% c("England", "Northern Ireland","Wales","Scotland"), "location"]),
        selected = "Germany"
      ),
      selectInput("model", "Select a time series model:",
        choices = c("ARIMA", "ETS"),
        selected = "ARIMA"
      ),
      selectInput("variable", "Select a variable:",
        choices = names(data)[5:length(names(data))],
        selected = "new_cases"
      ),
      dateInput("plot_slider", "Select a date:", value = as.Date("2022-06-01")),
      tableOutput("model_table"),
      tableOutput("model_performance")
    ),
    mainPanel(
      plotOutput("plot"),
      plotOutput("decomposition"),
      plotOutput("month_forecast"),
    )
  )
)

server <- function(input, output,session) {
  # Select country
  country_data <- reactive({
    data[data$location == input$country, ][, input$variable]
  })
  # na.omit
  data_country <- reactive({
    na.omit(country_data())
  })
  
  # Select month period and omit
  month_data <- reactive({
    data[data$location == input$country & as.Date(data$date) >= as.Date(input$plot_slider) - months(2) & as.Date(data$date) <= as.Date(input$plot_slider) + months(2), ][, input$variable]
  })
  data_month <- reactive({
    na.omit(month_data())
  })

  # Create a time series object for month data
  ts_month <- reactive({
    ts(data_month(), start = input$plot_slider, frequency = 60)
  })
  # Create a time series object for country data
  ts_country <- reactive({
    ts(data_country(), start = c(2020, 1), frequency = 365)
  })
  # Decompose the time series object
  ts_country_decomposed <- reactive({
    decompose(ts_country())
  })
  
  # Fit the model for monthly data
  fit_model_monthly <- reactive({
    if (input$model == "ARIMA") {
      auto.arima(ts_month())
    }else if (input$model == "ETS"){
      ets(ts_month())
    }
  })
  
  # Fit the model for all data
  fit_model_all <- reactive({
    if (input$model == "ARIMA") {
      auto.arima(ts_country())
    }else if (input$model == "ETS"){
      ets(ts_country())
    }
  })

  # Table for model information
  model_info <- reactive({
    if (input$model == "ARIMA") {
      arima_table <- data.frame(Model = "ARIMA", AIC = fit_model_monthly()$aic, BIC = fit_model_monthly()$bic)
      return(arima_table)
    }else if (input$model == "ETS"){
      ets_table <- data.frame(Model = "ETS", AIC = fit_model_monthly()$aic, BIC = fit_model_monthly()$bic)
      return(ets_table)
    }
  })
  
  # Table for model performance
  model_performance <- reactive({
    accuracy(fit_model_monthly())
  })
  
    # Table outputs
  output$model_table <- renderTable({
    model_info()
  })

  output$model_performance <- renderTable({
    model_performance()
  })

  # Update slider
  observeEvent(input$plot_slider, {
    updateSliderInput(session, "plot_slider", value = input$plot_slider)
  })
  
  # Plotting models
  output$plot <- renderPlot({
    forecast <- forecast(fit_model_all())
    if (input$model == "ARIMA") {
      plot(forecast, main = paste("COVID-19 Cases in", input$country, "using ARIMA model"), col = c("#333333", "#76A8D8"), xlab = "Date", ylab = "Cases", cex = 1.2)
      legend("topleft", legend = c("Observed", "Forecast"), col = c("#333333", "#76A8D8"), lty = 1, cex = 0.8)
    }else if (input$model == "ETS"){
      plot(forecast, main = paste("COVID-19 Cases in", input$country, "using ETS model"), col = c("#333333", "#76A8D8"), xlab = "Date", ylab = "Cases", cex = 1.2)
      legend("topleft", legend = c("Observed", "Forecast"), col = c("#333333", "#76A8D8"), lty = 1, cex = 0.8)
    }
  })
  
  output$decomposition <- renderPlot({
    ts_country_decomposed <- decompose(ts_country())
    plot(ts_country_decomposed, , xlab = "Date", ylab = "Cases", cex = 1.2)
    title(main = "", sub = paste("Decomposition of COVID-19 Cases in", input$country))
  })

  output$month_forecast <- renderPlot({
    forecast_month <- forecast(fit_model_monthly())
    if (input$model == "ARIMA") {
      plot(forecast_month, main = paste("Month-long Forecast of COVID-19 Cases in", input$country, "using ARIMA model"), col = c("#333333", "#76A8D8"), xlab = "Date", ylab = "Cases", cex = 1.2, xaxt = "n")
      legend("topleft", legend = c("Observed", "Forecast"), col = c("#333333", "#76A8D8"), lty = 1, cex = 0.8)
      title(main = "", sub = "Three Month Period Before The Selected Time")
    }else if (input$model == "ETS"){
      plot(forecast_month, main = paste("Month-long Forecast of COVID-19 Cases in", input$country, "using ETS model"), col = c("#333333", "#76A8D8"), xlab = "Date", ylab = "Cases", cex = 1.2, xaxt = "n")
      legend("topleft", legend = c("Observed", "Forecast"), col = c("#333333", "#76A8D8"), lty = 1, cex = 0.8)
      title(main = "", sub = "Three Month Period Before The Selected Time")
    }
  })
}
# Run the app
shinyApp(ui = ui, server = server)