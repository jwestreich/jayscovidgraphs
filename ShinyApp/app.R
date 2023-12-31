library(shiny)
library(ggplot2)
library(readr)
library(scales)
library(dplyr)

data <- read_csv("https://raw.githubusercontent.com/jwestreich/jayscovidgraphs/main/processed.csv")

ui <- fluidPage(
  titlePanel("Jay's COVID Graphs"),
  selectInput("state", "Choose a state:", unique(data$state)),
  plotOutput("cases_plot"),
  plotOutput("deaths_plot"),
  tags$footer(
    a(href = "https://github.com/jwestreich/jayscovidgraphs/blob/main/README.md", "See Documentation")
  )
)

server <- function(input, output) {
  filtered_data <- reactive({
    data %>% filter(state == input$state)
  })
  
  output$cases_plot <- renderPlot({
    ggplot(filtered_data(), aes(x = date)) +
      geom_bar(aes(y = new_cases_per100k), stat = "identity", fill = "steelblue3") +
      geom_line(aes(y = new_cases_per100k_smooth)) +
      labs(title = "New Daily Confirmed Cases") +
      ylim(0, 500) +
      theme_classic() +
      scale_x_date(limits=c(as.Date("2020-01-01"), as.Date("2023-01-01")), breaks=c(as.Date("2020-01-01"), as.Date("2020-07-01"), as.Date("2021-01-01"), as.Date("2021-07-01"), as.Date("2022-01-01"), as.Date("2022-07-01"), as.Date("2023-01-01")), labels=date_format("%m/%y")) +
      labs(x="Date") +
      labs(y = "New Cases per 100,000 Residents") +
      labs(caption = " ") +
      theme(panel.grid.major.y = element_line(color = "gray", size = 0.2),
            plot.title = element_text(hjust = 0.5, size = 20),
            axis.title.x = element_text(size = 16),
            axis.title.y = element_text(size = 16),
            axis.text.x = element_text(size = 14),
            axis.text.y = element_text(size = 14),
            plot.caption = element_text(size = 14))
  })
  
  output$deaths_plot <- renderPlot({
    ggplot(filtered_data(), aes(x = date)) +
      geom_bar(aes(y = new_deaths_per100k), stat = "identity", fill = "maroon") +
      geom_line(aes(y = new_deaths_per100k_smooth)) +
      labs(title = "New Daily Confirmed Deaths") +
      theme_classic() +
      scale_x_date(limits=c(as.Date("2020-01-01"), as.Date("2023-01-01")), breaks=c(as.Date("2020-01-01"), as.Date("2020-07-01"), as.Date("2021-01-01"), as.Date("2021-07-01"), as.Date("2022-01-01"), as.Date("2022-07-01"), as.Date("2023-01-01")), labels=date_format("%m/%y")) +
      labs(x="Date") +
      labs(y = "New Deaths per 100,000 Residents") +
      labs(caption = "Data from Johns Hopkins University") +
      theme(panel.grid.major.y = element_line(color = "gray", size = 0.2),
            plot.title = element_text(hjust = 0.5, size = 20),
            axis.title.x = element_text(size = 16),
            axis.title.y = element_text(size = 16),
            axis.text.x = element_text(size = 14),
            axis.text.y = element_text(size = 14),
            plot.caption = element_text(size = 14))+
      scale_y_continuous(limits = c(0, 6), breaks = seq(0, 6, by = 1))
  })
  
}

shinyApp(ui = ui, server = server)
