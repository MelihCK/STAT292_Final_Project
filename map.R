library(shiny)
library(leaflet)
library(dplyr)

# Importing data from the csv file and creating a list including the coordinates of the European capitals
data <- read.csv("owid-covid-data.csv")
european_capitals <- list(
  Austria = c(16.3738, 48.2082),
  Belgium = c(4.3517, 50.8503),
  Bulgaria = c(23.3219, 42.6977),
  Croatia = c(15.9819, 45.8150),
  Cyprus = c(33.3823, 35.1856),
  Czech_Republic = c(14.4378, 50.0755),
  Denmark = c(12.5683, 55.6761),
  Estonia = c(24.7536, 59.4370),
  Finland = c(24.9384, 60.1699),
  France = c(2.3522, 48.8566),
  Germany = c(13.4050, 52.5200),
  Greece = c(23.7275, 37.9838),
  Hungary = c(19.0402, 47.4979),
  Ireland = c(-6.2603, 53.3498),
  Italy = c(12.4964, 41.9028),
  Latvia = c(24.1052, 56.9496),
  Lithuania = c(25.2797, 54.6872),
  Luxembourg = c(6.1296, 49.8153),
  Malta = c(14.5146, 35.8989),
  Netherlands = c(4.8945, 52.3667),
  Poland = c(21.0122, 52.2297),
  Portugal = c(-9.1393, 38.7223),
  Romania = c(26.1025, 44.4268),
  Slovakia = c(17.1077, 48.1486),
  Slovenia = c(14.5058, 46.0569),
  Spain = c(-3.7038, 40.4168),
  Sweden = c(18.0686, 59.3293),
  United_Kingdom = c(-0.1278, 51.5074)
)
european_capitals_df <- data.frame(
  country = names(european_capitals),
  longitude = sapply(european_capitals, "[[", 1),
  latitude = sapply(european_capitals, "[[", 2)
)
# Creating the user interface
ui <- fluidPage(
  titlePanel("European Capitals"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("DatesMerge",
                  "Dates:",
                  min = as.Date(min(data$date), "%Y-%m-%d"),
                  max = as.Date(max(data$date), "%Y-%m-%d"),
                  value = as.Date("2020-08-27"),
                  timeFormat = "%Y-%m-%d"),
      selectInput("variable", "Select variable:", names(data)[5:length(names(data))], selected = "new_cases"),
      tableOutput("summary")
    ),
    mainPanel(
      leafletOutput("map", height = "800px")
    )
  )
)
server <- function(input, output) {
  # Map
  output$map <- renderLeaflet({
    data_filtered <- data %>%
      filter(date == input$DatesMerge)
    indices <- match(european_capitals_df$country, data_filtered$location)
    variable_values <- data_filtered[indices, input$variable]
    variable_values[is.na(variable_values)] <- "Data is not available"
    leaflet() %>%
      setView(lng = 15, lat = 55, zoom = 4) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addMarkers(
        lng = european_capitals_df$longitude,
        lat = european_capitals_df$latitude,
        popup = paste0(
          "<strong>", european_capitals_df$country, "</strong><br>",
          input$variable, ": ",
          variable_values
        ),
        data = european_capitals_df
      )
  })

  # Summary table
  output$summary <- renderTable({
      variable_values <- data[data$continent == "Europe", input$variable]
      variable_values <- na.omit(variable_values)
      summary_table <- data.frame(
        Statistic = c("Minimum", "Maximum", "Mean", "Median", "Standard Deviation", "Interquartile Range","First Quartile","Third Quartile"),
        Value = c(min(variable_values), max(variable_values), mean(variable_values,na.rm = TRUE), median(variable_values), sd(variable_values),IQR(variable_values),quantile(variable_values,0.25),quantile(variable_values,0.75)),
        stringsAsFactors = FALSE
      )
      return(summary_table)
    })
}
shinyApp(ui, server)
