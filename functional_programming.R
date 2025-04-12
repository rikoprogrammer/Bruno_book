

# recursive vs iterative functions

library(microbenchmark)

fact_iter <- function(n){
  result = 1
  for(i in 1:n){
    result = result * i
  }
  result
  
}

fact_recur <- function(n){
  if(n == 0 || n == 1){
    result = 1
  } else {
    n * fact_recur(n-1)
  }
}

microbenchmark::microbenchmark(
  fact_recur(50),
  fact_iter(50)
)


## Recursive fxns are slower than their iterative equivalents. 
# If you want to make recursive functions faster you can use either trampoline
## package or memoise package


## UNIX PHILOSOPHY - Write programs that do one thing and do it well


## Loops

result <- 0

for (i in 1:100) {
  
  result <- result + i
  
}

result


#instead of the for loop we write a function that does the looping

looping <- function(a_list, a_func, init = NULL, ...){
  
  # If the user does not provide an `init` value,
  # set the head of the list as the initial value
  if(is.null(init)){
    init <- a_list[[1]]
    a_list <- tail(a_list, -1)
  }
  # Separate the head from the tail of the list
  # and apply the function to the initial value and the head of the list
  head_list = a_list[[1]]
  tail_list = tail(a_list, -1)
  init = a_func(init, head_list, ...)
  
  # Check if we're done: if there is still some tail,
  # rerun the whole thing until there's no tail left
  
  if(length(tail_list) != 0){
    looping(tail_list, a_func, init, ...)
  }
  else {
    init
  }
}

looping(as.list(seq(1:100)), `+`)

# we can use the built in function Reduce() to achieve similar results

Reduce(`+`, seq(1:100))

# we can use higher order functions implemented in purrr to abstract loops a way

library(purrr)

rep(1, 100) %*% seq(1, 100)


## data frames - these are implemented as lists and therefore we can apply 
## looping functions on them as well


unemp_path <- tempfile(fileext = ".rda")

# Download the data and save it to the path of the temporary file
# avoids having to install the package from Github

download.file(
  "https://is.gd/l57cNX",
  destfile = unemp_path)

# Load the data. The data is now available as 'unemp'


load(unemp_path) 

# the above download code doesnt work, had to download the file manually and save it to the datasets folder


unemp_path <- load("datasets/unemp.rda")

library(dplyr)
library(purrr)
library(ggplot2)
library(tidyr)

glimpse(unemp)


filtered_unemp <- unemp |> 
  filter(
    level == "Commune",
    place_name %in% c("Luxembourg",
                      "Esch-sur-Alzette", "Wiltz")
  )

glimpse(filtered_unemp)

nested_unemp <- filtered_unemp |> 
  group_nest(place_name)

nested_unemp

nested_unemp |> 
  mutate(nrows = map_int(data, nrow))


#create plots

lux_data <- nested_unemp |> 
  filter(place_name == "Luxembourg") |> 
  unnest(data)

ggplot(data = lux_data) +
  theme_minimal() +
  geom_line(
    aes(year, unemployment_rate_in_percent, group = 1) 
  ) +
  labs(title = "Unemployment in Luxembourg")


#turn it into a function

make_plot <- function(x, y) {
  
  ggplot(data = x) +
    theme_minimal() +
    geom_line(
      aes(year, unemployment_rate_in_percent, group = 1)
    ) +
    labs(title = paste("Unemployment in", y),
         y = "Unemployment Rate (%)")
}

make_plot(lux_data, "Luxembourg")

# apply this function to our nested data frame

nested_unemp <- nested_unemp |> 
  mutate(plots = map2(
    .x = data, #column of data frames
    .y = place_name, # column of commune names
    .f = make_plot
  ))

nested_unemp

nested_unemp$plots


## 4TH APRIL 2025

# an example of a function that is not referentially transparent

h <- function(name, food_list = list()){
  food <- sample(c("lasagna", "cassoulet", "feijoada"), 1)
  food_list <- append(food_list, food)
  print(paste0(name, " likes ", food))
  food_list
}

h("Eric")
h("Eric")


h <- function(name, food_list = list(), seed=123){
  
  set.seed(seed)
  food <- sample(c("lasagna", "cassoulet", "feijoada"), 1)
  food_list <- append(food_list, food)
  print(paste0(name, " likes ", food))
  food_list
}

h("Eric")
h("Eric")
h("Eric")

#instead of modifying the function we can use withr::with_seed as shown below

library(withr)

h <- function(name, food_list = list()){
  food <- sample(c("lasagna", "cassoulet", "feijoada"), 1)
  food_list <- append(food_list, food)
  print(paste0(name, " likes ", food))
  food_list
}

withr::with_seed(seed = 123, h("Eric"))
withr::with_seed(seed = 123, h("Eric"))
withr::with_seed(seed = 123, h("Eric"))

# withr::with_tempfile("unemp", {
#   download.file(
#     "https://www.is.gd/l57cNX",
#     destfile = unemp)
#   load(unemp)
#   nrow(unemp)
# }
# )
