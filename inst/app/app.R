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
  layout_columns(
    value_box(
      title = "Your best bet",
      value = textOutput("top_spot"),
      showcase = icon("location-dot")
    ),
    value_box(
      title = "People walking past per hour",
      value = textOutput("top_count"),
      showcase = icon("person-walking")
    ),
    value_box(
      title = "Lead over 2nd place",
      value = textOutput("lead"),
      showcase = icon("fire")
    )
  ),
  card(
    card_header("Top 10 spots for your trading hours"),
    textOutput("finding"),
    plotOutput("rank_plot")
  ),
  card(
    card_header("When does it get busy?"),
    p("The shaded band is your opening hours. You want the line to peak inside it."),
    plotOutput("hour_plot")
  )
)

server <- function(input, output, session) {
  
  # The one shared calculation: every output below reads from this
  ranked <- reactive({
    rank_locations(foot_traffic, sensors,
                   days = input$days, hours = input$hours)
  }, label = "ranked")
  
  output$top_spot <- renderText({
    ranked()$location_name[1]
  })
  
  output$top_count <- renderText({
    format(ranked()$avg_per_hour[1], big.mark = ",")
  })
  
  output$lead <- renderText({
    top <- ranked()
    lead <- (top$avg_per_hour[1] / top$avg_per_hour[2] - 1) * 100
    paste0(round(lead), "% busier")
  })
  
  output$finding <- renderText({
    top <- ranked()
    paste0(
      "Open ", paste(input$days, collapse = ", "),
      " from ", input$hours[1], ":00 to ", input$hours[2], ":00? ",
      top$location_name[1], " is your spot, with about ",
      format(top$avg_per_hour[1], big.mark = ","),
      " people walking past every hour."
    )
  })
  
  output$rank_plot <- renderPlot({
    ranked() |>
      head(10) |>
      ggplot(aes(x = avg_per_hour,
                 y = reorder(location_name, avg_per_hour))) +
      geom_col()
  })

  output$hour_plot <- renderPlot({
    top3 <- ranked() |> head(3)
    
    hourly_profile(foot_traffic, sensors, top3$location_id,
                   days = input$days) |>
      # Keep the legend in rank order, not alphabetical
      dplyr::mutate(location_name = factor(location_name,
                                           levels = top3$location_name)) |>
      ggplot(aes(x = hour, y = avg_per_hour, colour = location_name)) +
      annotate("rect",
               xmin = input$hours[1], xmax = input$hours[2],
               ymin = -Inf, ymax = Inf, alpha = 0.2) +
      geom_line(linewidth = 1)
  })
}

shinyApp(ui, server)