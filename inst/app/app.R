library(shiny)
library(bslib)
library(ggplot2)
library(melbfoot)

# Retro palette, shared by the theme and both plots
scout <- c(
  butter = "#FFF2A7",
  wine   = "#930031",
  orange = "#FFA500",
  sky    = "#BEDEFF",
  mint   = "#C5EBC3"
)

# Turn 10 into "10am", 18 into "6pm" and so on
fmt_hour <- function(h) {
  if (h == 0 || h == 24) return("midnight")
  if (h == 12) return("noon")
  if (h < 12) paste0(h, "am") else paste0(h - 12, "pm")
}

# One reusable plot theme so both charts match
theme_scout <- function() {
  theme_minimal(base_size = 15) +
    theme(
      text = element_text(colour = scout[["wine"]]),
      axis.text = element_text(colour = scout[["wine"]]),
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.major.x = element_line(colour = scout[["sky"]]),
      legend.position = "bottom"
    )
}

ui <- page_sidebar(
  title = "Pop-Up Scout",
  fillable = FALSE,
  theme = bs_theme(
    bg = scout[["butter"]],
    fg = scout[["wine"]],
    primary = scout[["wine"]],
    base_font = font_google("DM Sans"),
    heading_font = font_google("Shrikhand")
  ),
  tags$head(
    tags$link(
      rel = "stylesheet",
      href = "https://fonts.googleapis.com/css2?family=Fraunces:ital,wght@1,600&display=swap"
    ),
    tags$link(rel = "stylesheet", href = "styles.css")
  ),

  sidebar = sidebar(
    bg = scout[["sky"]],
    checkboxGroupInput(
      "days", "When are you open?",
      choices = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"),
      selected = c("Sat", "Sun")
    ),
    helpText("Tick every day your shop will trade. Counts are averaged across these days."),

    sliderInput(
      "hours", "Opening hours",
      min = 0, max = 24, value = c(10, 18), step = 1
    ),
    helpText("Drag both ends to your opening and closing time. 10 to 18 means 10am to 6pm."),

    checkboxGroupInput(
      "months", "Which months?",
      choices = month.abb, selected = month.abb, inline = TRUE
    ),
    div(
      actionButton("xmas", "🎄 Christmas only", class = "btn-scout"),
      actionButton("all_year", "All year", class = "btn-scout")
    ),
    helpText("Untick any months you won't trade, or use a shortcut."),

    hr(),
    helpText(
      "Data: City of Melbourne Pedestrian Counting System, Oct 2025 to Sep 2026,",
      "100 outdoor street sensors. Counts are people walking past, not shoppers."
    )
  ),

  card(
    card_header("Thinking of opening a pop-up in the CBD?"),
    p(
      "Pop-Up Scout is for anyone planning a short-term clothing pop-up in",
      "Melbourne's CBD. It answers one question:",
      strong("which street-front spot gets the most people walking past during",
             "the hours you'd actually be open?")
    ),
    tags$ol(
      tags$li("Tick the days you'll trade."),
      tags$li("Set your opening hours."),
      tags$li("Pick the months you'll be open."),
      tags$li("Read your best bet below. Everything updates straight away.")
    )
  ),

  layout_columns(
    gap = "1.5rem",
    value_box(
      title = "Your best bet",
      value = textOutput("top_spot"),
      showcase = icon("location-dot"),
      theme = value_box_theme(bg = scout[["orange"]], fg = scout[["wine"]])
    ),
    value_box(
      title = "People walking past per hour",
      value = textOutput("top_count"),
      showcase = icon("person-walking"),
      theme = value_box_theme(bg = scout[["sky"]], fg = scout[["wine"]])
    ),
    value_box(
      title = "Lead over 2nd place",
      value = textOutput("lead"),
      showcase = icon("fire"),
      theme = value_box_theme(bg = scout[["sky"]], fg = scout[["wine"]])
    )
  ),

  card(
    card_header("Top 10 spots for your trading hours"),
    textOutput("finding"),
    p(
      "Each bar is one street location. A longer bar means more people walk",
      "past each hour while you're open. Your top pick is orange. If two bars",
      "are close, the spots are basically tied, so let rent and vibe decide."
    ),
    plotOutput("rank_plot", height = "400px"),
    textOutput("data_note")
  ),

  card(
    card_header("When does it get busy?"),
    p(
      "Each line is one of your top 3 spots. The blue band is your opening",
      "hours. You want the line to peak inside it. A peak outside the band",
      "means the crowds come when you're closed."
    ),
    plotOutput("hour_plot", height = "350px")
  )
)

server <- function(input, output, session) {

  # TRUE when the inputs make sense, used to keep the value boxes quiet
  ready <- reactive({
    length(input$days) > 0 &&
      length(input$months) > 0 &&
      input$hours[1] < input$hours[2]
  })

  # Shortcut buttons: tick a preset set of months
  observeEvent(input$xmas, {
    updateCheckboxGroupInput(session, "months", selected = c("Nov", "Dec"))
  })

  observeEvent(input$all_year, {
    updateCheckboxGroupInput(session, "months", selected = month.abb)
  })

  # The one shared calculation: every output below reads from this
  ranked <- reactive({
    validate(
      need(length(input$days) > 0,
           "Tick at least one day you'll be open and your rankings will appear."),
      need(length(input$months) > 0,
           "Pick at least one month to trade in."),
      need(input$hours[1] < input$hours[2],
           "Your opening and closing times are the same. Drag the slider so you're open for at least an hour.")
    )
    rank_locations(foot_traffic, sensors,
                   days = input$days, hours = input$hours,
                   months = input$months)
  }, label = "ranked")

  output$top_spot <- renderText({
    req(ready())
    ranked()$location_name[1]
  })

  output$top_count <- renderText({
    req(ready())
    format(ranked()$avg_per_hour[1], big.mark = ",")
  })

  output$lead <- renderText({
    req(ready())
    top <- ranked()
    lead <- (top$avg_per_hour[1] / top$avg_per_hour[2] - 1) * 100
    paste0(round(lead), "% busier")
  })

  output$finding <- renderText({
    top <- ranked()
    msg <- paste0(
      "Open ", paste(input$days, collapse = ", "),
      " from ", fmt_hour(input$hours[1]), " to ", fmt_hour(input$hours[2]), "? ",
      top$location_name[1], " is your spot, with about ",
      format(top$avg_per_hour[1], big.mark = ","),
      " people walking past every hour."
    )
    if (top$avg_per_hour[1] < 150) {
      msg <- paste(msg, "Heads up: even the busiest spot is pretty quiet at",
                   "these times, so a pop-up might struggle.")
    }
    if (top$limited_data[1]) {
      msg <- paste(msg, "Careful though: this sensor only reported on",
                   top$days_observed[1], "of 365 days, so its average is",
                   "shakier than the rest.")
    }
    msg
  })

  output$data_note <- renderText({
    req(ready())
    top10 <- head(ranked(), 10)
    flagged <- top10$location_name[top10$limited_data]
    if (length(flagged) == 0) return("")
    paste0(
      "Hollow bars come from sensors that missed a lot of days (",
      paste(flagged, collapse = ", "),
      "), so their averages are less reliable."
    )
  })

  output$rank_plot <- renderPlot({
    req(ready())
    ranked() |>
      head(10) |>
      dplyr::mutate(status = dplyr::case_when(
        limited_data ~ "Limited data",
        rank == 1    ~ "Top pick",
        TRUE         ~ "Contender"
      )) |>
      ggplot(aes(x = avg_per_hour,
                 y = reorder(location_name, avg_per_hour),
                 fill = status)) +
      geom_col(colour = scout[["wine"]], linewidth = 0.8, width = 0.7) +
      scale_fill_manual(
        values = c("Top pick"     = scout[["orange"]],
                   "Contender"    = scout[["sky"]],
                   "Limited data" = scout[["butter"]]),
        guide = "none"
      ) +
      scale_x_continuous(labels = function(x) format(x, big.mark = ",")) +
      labs(x = "People walking past per hour while you're open", y = NULL) +
      theme_scout()
  }, bg = "transparent")

  output$hour_plot <- renderPlot({
    top3 <- ranked() |> head(3)

    hourly_profile(foot_traffic, sensors, top3$location_id,
                   days = input$days, months = input$months) |>
      # Keep the legend in rank order, not alphabetical
      dplyr::mutate(location_name = factor(location_name,
                                           levels = top3$location_name)) |>
      ggplot(aes(x = hour, y = avg_per_hour, linetype = location_name)) +
      annotate("rect",
               xmin = input$hours[1], xmax = input$hours[2],
               ymin = -Inf, ymax = Inf,
               fill = scout[["sky"]], alpha = 0.7) +
      geom_line(colour = scout[["wine"]], linewidth = 1.3) +
      scale_linetype_manual(values = c("solid", "42", "11")) +
      scale_x_continuous(
        breaks = c(0, 6, 12, 18, 24),
        labels = c("midnight", "6am", "noon", "6pm", "midnight"),
        limits = c(0, 24)
      ) +
      scale_y_continuous(labels = function(x) format(x, big.mark = ",")) +
      labs(x = NULL, y = "People per hour", linetype = NULL) +
      theme_scout() +
      theme(
        panel.grid.major.y = element_line(colour = scout[["sky"]]),
        panel.grid.major.x = element_blank(),
        legend.key.width = unit(2.5, "lines")
      )
  }, bg = "transparent")
}

shinyApp(ui, server)
