#
# Homework 9 (hw_9)
# Group Maddie, Daniel, David
#

library(tidyverse)
library(shiny)


ui <- fluidPage(

    # Application title
  titlePanel(
    p(
      h1("MPG Dataset Shiny App",align="center"),
      br(),
      h5("This application will show a summary of the data in the MPG dataset. 
         Please use the slider to adjust the year of interest.",align="center"),
      h6("Group Members: Maddie, Daniel, David",align="center"),
      br()
    )),

    # Slider for Year of Manufacturer
    sidebarLayout(
        sidebarPanel(
            sliderInput("year",
                        "Year of Manufacturer:",
                        min = min(mpg$year),
                        max = max(mpg$year),
                        value = min(mpg$year),
                        step = 10,
                        sep="")
        ),

        mainPanel(
           tableOutput("vehicle_data"),
           plotOutput("cityhistPlot"),
           plotOutput("hwyhistPlot")
        )
    )
)

server <- function(input, output) {

  #Saving data in separate variables to make is clearer to look at
mpg_cty <- reactive({
  mpg %>%
  filter(year == input$year) %>%
  summarize(mean = mean(cty,na.rm = TRUE)) %>%
  round(2)
  })

mpg_hwy <- reactive({
  mpg %>%
    filter(year == input$year) %>%
    summarize(mean = mean(hwy,na.rm = TRUE)) %>%
    round(2)
}) 

unique_mfg <- reactive({
  mpg %>%
    filter(year == input$year) %>%
    summarise(n_distinct(manufacturer))
}) 

unique_model <- reactive({
  mpg %>%
    filter(year == input$year) %>%
    summarise(n_distinct(model))
}) 

mean_displacement <- reactive({
  mpg %>%
    filter(year == input$year) %>%
    summarise(mean(displ)) %>%
    round(2)
})


#This sets up the table of data to show on the Tiny Web App
VehicleDataValues <- reactive({
  data.frame(
    Name = c("City MPG (mean)",
             "Highway MPG (mean)",
             "# of Manufacturers",
             "# of Models",
             "Engine Displacement"),
    Value = as.character(c(mpg_cty(),
                           mpg_hwy(),
                           unique_mfg(),
                           unique_model(),
                           mean_displacement()
                           )),
    stringsAsFactors = FALSE)
})


#This redners the Table
    output$vehicle_data <- renderTable({
      VehicleDataValues()
    })

    #This provides the histogram outputs 
    output$cityhistPlot <- renderPlot({
      x <- mpg %>% filter(year == input$year)
      hist(x$cty, 10, 
           col = 'darkgray', 
           border = 'white',
           main=paste("City Miles per Gallon for",input$year,"Histogram"),
           xlab="MPG")
    })
    
    output$hwyhistPlot <- renderPlot({
      x <- mpg %>% filter(year == input$year)
      hist(x$hwy, 10, 
           col = 'darkgray', 
           border = 'white',
           main=paste("Highway Miles per Gallon for",input$year,"Histogram"),
           xlab="MPG")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
