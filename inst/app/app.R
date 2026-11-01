library(shiny)
library(bslib)
library(ggplot2)
library(melbfoot)

ui <- page_sidebar(
  title = "Pop-Up Scout",
  sidebar = sidebar(
    checkboxGroupInput(
      "days", "When are you open?",
      choices = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"),
      selected = c("Sat", "Sun")
    ),
    sliderInput(
      "hours", "Opening hours",
      min = 0, max = 24, value = c(10, 18), step = 1
    )
  ),
  plotOutput("rank_plot")
)

server <- function(input, output, session) {
  output$rank_plot <- renderPlot({
    rank_locations(foot_traffic, sensors,
                   days = input$days, hours = input$hours) |>
      head(10) |>
      ggplot(aes(x = avg_per_hour,
                 y = reorder(location_name, avg_per_hour))) +
      geom_col()
  })
}

shinyApp(ui, server)