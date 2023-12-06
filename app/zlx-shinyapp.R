library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)
library(DT)
library(leaflet)
library(ggplot2)

ui <- fluidPage(
  titlePanel("CA Santa Barbara County Hotel Business Evaluation"),
  tags$head(
    tags$style(HTML("
      body, html {
        height: 100%;
        margin: 0;
        padding: 0;
      }
      .container-fluid {
        display: flex; /* Enable flexbox */
        flex-direction: column; /* Stack elements vertically */
        height: 100%;
      }
      .sidebarLayout .sidebarPanel, .sidebarLayout .mainPanel {
        overflow-y: auto; /* Add scroll to each panel if content overflows */
        height: 100%; /* Adjust height to fill container */
      }
      .leaflet-container {
        height: 500px; /* Adjust leaflet map height */
      }
    ")),
    tags$meta(name="viewport", content="width=device-width, initial-scale=1.0")
  ),
  
  tabsetPanel(
    tabPanel("I want to own a hotel",
             sidebarLayout(
               sidebarPanel(
                 checkboxGroupInput("attributes", "Choose Attributes:",
                                    choices = list("WheelchairAccessible" = "wheelchair",
                                                   "BikeParking" = "bike",
                                                   "ByAppointmentOnly" = "appointment",
                                                   "DogsAllowed" = "dogs",
                                                   "GoodForKids" = "kids",
                                                   "BusinessAcceotsCreditCards" = "creditcard",
                                                   "RestaurantsReservations" = "reservation",
                                                   "RestaurantsDelivery" = "delivery",
                                                   "RestaurantsAttire" = "attire",
                                                   "RestaurantsGoodForGroups" = "groups",
                                                   "RestaurantsTableService" = "table")),
                 selectInput("wifi", "WiFi:",
                             choices = c("no-wifi", "free-wifi", "paid-wifi"), selected='no-wifi'),
                 selectInput("price2", "Restaurants Price Range 2:",
                             choices = c("0", "1", "2", "3", "4"), selected='0'),
                 selectInput("trips", "Number of Trips:",
                             choices = c("Santa Barbara", "Carpinteria", "Montecito",
                                         "Goleta", "SANTA BARBARA AP", "Summerland"),
                             selected='Santa Barara')
               ),
               mainPanel(
                 textOutput("selectedOutput"),
                 leafletOutput("mapOutput", height = '568px'),
                 plotOutput("ratingPlot"),  # boxplot 
                 textOutput("percentileOutput") 
               )
             ),
             tags$div(class="footer", align = "center",style = "color: #cc340c;",
                      HTML("If you have any questions about the model or any improvements, please contact us.<br>Contact: lzhang699@wisc.edu; <br> yren86@wisc.edu; <br> zheng275@wisc.edu."))
    
    ),
    
    
    tabPanel("I already own a hotel",
             sidebarLayout(
               sidebarPanel(
                 selectInput("postal_code", "Select your hotel zip code:", choices = NULL),
                 selectInput("hotel_name", "Select your hotel name:", choices = NULL)
               ),
               mainPanel(
                 leafletOutput("mapOutput2", height = '568px'),
                 plotOutput("hotelRatingPlot")  # box
               )
             ),
             
             tags$div(class="footer", align = "center",style = "color: #cc340c;",
                      HTML("If you have any questions about the model or any improvements, please contact us.<br>Contact: lzhang699@wisc.edu; <br> yren86@wisc.edu; <br> zheng275@wisc.edu."))
    
    )
  )
)






server <- function(input, output, session) {
    df <- read.csv('scaledata.csv')
    
    updateSelectInput(session, "postal_code", choices = unique(df$postal_code))
    
  
    selected_attributes <- reactive({
        input$attributes
    })
    
    wheelchair <- reactive({
        if("wheelchair" %in% selected_attributes()) {
            1
        } else {
            0
        }
    })
    
    bike <- reactive({
        if("bike" %in% selected_attributes()) {
            1
        } else {
            0
        }
    })
    
    appointment <- reactive({
        if("appoinment" %in% selected_attributes()) {
            1
        } else {
            0
        }
    })
    
    dogs <- reactive({
        if("dogs" %in% selected_attributes()) {
            1
        } else {
            0
        }
    })
    
    kids <- reactive({
        if("kids" %in% selected_attributes()) {
            1
        } else {
            0
        }
    })
    
    creditcard <- reactive({
        if("creditcard" %in% selected_attributes()) {
            1
        } else {
            0
        }
    })
    
    wifi <- reactive({
        val <- input$wifi
        if (val == 'no-wifi') {
            0
        } else if (val == 'free-wifi') {
            1
        } else if (val == 'paid-wifi') {
            2
        } else {
            0  # Default value if none of the above
        }
    })
    
    
    price2 <- reactive({
        as.numeric(input$price2)
    })
    
    
    reservation <- reactive({
        if("reservation" %in% selected_attributes()) {
            1
        } else {
            0
        }
    })
    
    delivery <- reactive({
        if("delivery" %in% selected_attributes()) {
            1
        } else {
            0
        }
    })
    
    attire <- reactive({
        if("attire" %in% selected_attributes()) {
            1
        } else {
            0
        }
    })
    
    groups <- reactive({
        if("groups" %in% selected_attributes()) {
            1
        } else {
            0
        }
    })
    
    table <- reactive({
        if("table" %in% selected_attributes()) {
            1
        } else {
            0
        }
    })
    
    trips <- reactive({
        input$trips # return a city name
    })
    
    predicted_rating <- reactive({
        wheelchair_val <- wheelchair()
        bike_val <- bike()
        appointment_val <- appointment()
        dogs_val <- dogs()
        kids_val <- kids()
        wifi_val <- wifi()
        creditcard_val <- creditcard()
        reservation_val <- reservation()
        delivery_val <- delivery()
        attire_val <- attire()
        groups_val <- groups()
        table_val <- table()
        price2_val <- price2()
        trips_val <- trips() 
        
        avg_trip <- 0
        
        if (trips_val == 'Santa Barbara' | trips_val == 'SANTA BARBARA AP') {
            avg_trip <- mean(df$Number.of.Trips[df$city == "Santa Barbara" | df$city == "SANTA BARBARA AP"])
        } else {
            avg_trip <- mean(df$Number.of.Trips[df$city==trips_val])
        }
        
        rating <- 3.78945 + 0.3449 * wheelchair_val + 0.40396 * bike_val + 
            0.14645 * appointment_val - 0.23009 * dogs_val + 0.36834 * kids_val +
            0.07981 * creditcard_val - 0.14095 * wifi_val - 0.05202 * price2_val +
            0.63085 * reservation_val + 1.02001 * delivery_val - 2.11767 * attire_val +
            0.18537 * groups_val - 1.15036 * table_val + 0.07984 * avg_trip
        
        if (rating < 0) {
            rating <- 0
        } else if (rating > 5) {
            rating <- 5
        }
        
        return(rating)
    })
    
    
    output$selectedOutput <- renderText({
        rating <- predicted_rating()
        # print(rating)
        paste0('Your predicted star rating(1-5) in CA Santa Barbara County Hotel Business is: ', round(rating, 2))
    })
    
    ########## Change
    
    
    output$mapOutput <- renderLeaflet({
        trips_val <- trips()
        df <- read.csv('scaledata.csv')
        df$popup_label <- paste(df$name, "<br>Rating:", df$stars_review)  
        df <- df[df$city == trips_val,]
        
        map <- leaflet(df) %>%
            addTiles() %>%
            setView(lng = -119.698190, lat = 34.420830, zoom = 10)
        
        
        map %>%
            addCircleMarkers(
                lng = ~longitude, lat = ~latitude,
                radius = 8,  
                color = '#007bff', 
                popup = ~popup_label,  # Add popups
                labelOptions = labelOptions(noHide = FALSE, direction = 'auto')
            )
    })
    
    
    
    
    
    ############## Change
    
    output$ratingPlot <- renderPlot({
      predicted <- predicted_rating()
      df_for_plot <- data.frame(rating = df$stars_business, type = "Actual Ratings")
      combined_df <- rbind(df_for_plot, data.frame(rating = predicted, type = "Predicted"))
      
      percentile <- mean(df$stars_business <= predicted) * 100
      percentile_label <- paste("Predicted: ", round(predicted, 2),
                                "\nTop ", round(percentile, 2), "% Percentile", sep = "")
      
      p <- ggplot(combined_df, aes(x = type, y = rating)) +
        geom_boxplot() +
        geom_point(data = subset(combined_df, type == "Predicted"), aes(x = type, y = rating), 
                   color = "red", size = 4) +
        geom_text(x = 2.5, y = max(df$stars_business) * 0.9, 
                  label = percentile_label, hjust =1, vjust = 0, 
                  color = "red", size = 5) +
        labs(title = "Hotel Ratings", y = "Rating", x = "") +
        theme_minimal() +
        theme(plot.title = element_text(hjust = 0.5))
      
      print(p)
    })
    
    
    ######### 尝试第二个panel
    
    observeEvent(input$postal_code, {
      df_filtered <- df[df$postal_code == input$postal_code, ]
      hotel_names <- unique(df_filtered$name)
      
      print(paste("Postal code:", input$postal_code))
      print(hotel_names)
      
      updateSelectInput(session, "hotel_name", choices = hotel_names)
    })
    
    
    
    output$mapOutput2 <- renderLeaflet({
      selected_postal_code <- input$postal_code
      selected_hotel_name <- input$hotel_name
      
      if (!is.null(selected_postal_code) && !is.null(selected_hotel_name)) {
        df$color <- ifelse(df$name == selected_hotel_name, "red", '#007bff')
      } else {
        df$color <- '#007bff'
      }
      
      leaflet(df) %>%
        addTiles() %>%
        addCircleMarkers(
          lng = ~longitude, lat = ~latitude,
          color = ~color,
          popup = ~paste(name, "<br>Rating:", stars_review)
        )
    })
    
    
    output$hotelRatingPlot <- renderPlot({
      selected_postal_code <- input$postal_code
      selected_hotel_name <- input$hotel_name
      
      if (!is.null(selected_postal_code) && !is.null(selected_hotel_name)) {
        selected_hotel <- df[df$postal_code == selected_postal_code & df$name == selected_hotel_name, ]
        selected_rating <- ifelse(nrow(selected_hotel) > 0, selected_hotel$stars_review, NA)
        
        if (!is.null(selected_rating) && length(selected_rating) == 1 && !is.na(selected_rating)) {
          percentile <- mean(df$stars_review <= selected_rating) * 100
          percentile_label <- paste("Your Rating: ", round(selected_rating, 2),
                                    "\nTop ", round(percentile, 2), "% Percentile", sep = "")
          
          p <- ggplot(df, aes(x = "", y = stars_review)) +
            geom_boxplot() +
            geom_point(aes(y = selected_rating), color = "red", size = 4) +
            geom_text(x = 1.5, y = max(df$stars_review) * 0.9, 
                      label = percentile_label, hjust = 1, vjust = 0, 
                      color = "red", size = 5) +
            labs(title = "Hotel Rating Comparison", y = "Rating", x = "") +
            theme_minimal() +
            theme(plot.title = element_text(hjust = 0.5))
          
          print(p)
        }
      }
    })
    

    
}

shinyApp(ui = ui, server = server)
