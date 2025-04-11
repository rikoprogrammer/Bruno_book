


### ANALYSIS

library(tidyr)
library(ggplot2)
library(dplyr)

commune_level_data <- read.csv("datasets/commune_level_data.csv")
country_level_data <- read.csv("datasets/country_level_data.csv")

#Let's compute the Laspeyeres index for each commune:

commune_level_data <- commune_level_data |> 
  group_by(locality)  |> 
  mutate(p0 = ifelse(year == "2010", average_price_nominal_euros, NA))  |> 
  fill(p0, .direction = "down") |> 
  mutate(p0_m2 = ifelse(year == "2010", average_price_m2_nominal_euros, NA)) |> 
  fill(p0_m2, .direction = "down") |> 
  ungroup() |> 
  mutate(pl = average_price_nominal_euros/p0*100,
         pl_m2 = average_price_m2_nominal_euros/p0_m2*100)


#Let's also compute it for the whole country:

country_level_data <- country_level_data %>%
  mutate(p0 = ifelse(year == "2010", average_price_nominal_euros, NA)) %>%
  fill(p0, .direction = "down") %>%
  mutate(p0_m2 = ifelse(year == "2010", average_price_m2_nominal_euros, NA)) %>%
  fill(p0_m2, .direction = "down") %>%
  mutate(pl = average_price_nominal_euros/p0*100,
         pl_m2 = average_price_m2_nominal_euros/p0_m2*100)


#We are going to create a plot for 5 communes and compare the price evolution in the communes
#to the national price evolution. Let's first list the communes:

communes <- c("Luxembourg",
              "Esch-sur-Alzette",
              "Mamer",
              "Schengen",
              "Wincrange")

# Luxembourg

filtered_data <- commune_level_data %>%
  filter(locality == communes[1])

# data_to_plot <- bind_rows(
#   country_level_data,
#   filtered_data
# )


# make a plot function

make_plot <- function(country_level_data,
                      commune_level_data,
                      commune){
  
  filtered_data <- commune_level_data %>%
    filter(locality == commune)
  
  data_to_plot <- bind_rows(
    country_level_data,
    filtered_data
  )
  ggplot(data_to_plot) +
    geom_line(aes(y = pl_m2,
                  x = year,
                  group = locality,
                  colour = locality))
}

# 
# lux_plot <- ggplot(data_to_plot) +
#   geom_line(aes(y = pl_m2,
#                 x = year,
#                 group = locality,
#                 colour = locality))

lux_plot <- make_plot(country_level_data,
                      commune_level_data,
                      communes[1])

lux_plot

esch_plot <- make_plot(country_level_data,
                       commune_level_data,
                       communes[2])
esch_plot

