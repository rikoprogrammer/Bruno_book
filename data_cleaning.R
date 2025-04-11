

## Reproducible Analytical Pipeline - RAP 

### The tools are always right. If you're using a tool and it's not behaving
##  as expected, it is much more likely that your expectations are wrong. Take
##  this opportunity to review your knowledge of the tool.




library(dplyr)
library(purrr)
library(readxl)
library(stringr)
library(janitor)


# the url below points to an excel file hosted on the book's github repository

#raw url: url <- "https://github.com/b-rodrigues/rap4all/raw/master/datasets/vente-maison-2010-2021.xlsx"
#url <- "https://is.gd/1vvBAc"
url <- "https://www.is.gd/1vvBAc"


raw_data <- tempfile(fileext = ".xlsx")

download.file(url, raw_data, 
              method = 'auto', 
              mode = "wb")


sheets <- excel_sheets(raw_data)

read_clean <- function(..., sheet){
  read_excel(..., sheet = sheet) |>
    mutate(year = sheet)
}


raw_data <- map(
  sheets,
  ~read_clean(raw_data,
              skip = 10,
              sheet = .)) |>
  bind_rows() |>
  clean_names()


raw_data <- raw_data |>
  rename(
    locality = commune,
    n_offers = nombre_doffres,
    average_price_nominal_euros =
    prix_moyen_annonce_en_courant,
    average_price_m2_nominal_euros =
    prix_moyen_annonce_au_m2_en_courant,
    average_price_m2_nominal_euros =
    prix_moyen_annonce_au_m2_en_courant
  ) |>
  mutate(locality = str_trim(locality)) |>
  select(year, locality, n_offers,
         starts_with("average"))


raw_data |> 
  filter(grepl('Luxembourg', locality)) |> 
  count(locality)

raw_data |> 
  filter(grepl("P.tange", locality)) |> 
  count(locality)


#correct naming inconsistencies in the locality column

raw_data <- raw_data |> 
  mutate(
    locality = ifelse(grepl("Luxembourg-Ville", locality), "Luxembourg", 
                      locality),
    locality = ifelse(grepl("P.tange", locality), "Pétange", locality)
  ) |> 
  mutate(across(starts_with('average'), as.numeric))


raw_data |> 
  filter(is.na(average_price_nominal_euros))

#remove rows stating the sources

raw_data <- raw_data |> 
  filter(!grepl("Source", locality))

# next time remember to save the above file locally -- 3rd April 2024
# save a copy locally, just incase the url above fails to work again

# saveRDS(raw_data, 'raw_data.rds')
# raw_data <- readRDS('raw_data.rds')

# let's only keep the communes in our data

# commune_level_data <- raw_data |> 
#   filter(!grepl("nationale|offers", locality), !is.na(locality))

#corrected the above code from the text book, it should be offres not offers

commune_level_data <- raw_data |> 
  filter(!grepl("nationale|offres", locality), !is.na(locality))

#lets create  a dataset with the national data as well

country_level <- raw_data |> 
  filter(grepl("nationale", locality)) |> 
  select(-n_offers)

offers_country <- raw_data |> 
  filter(grepl("Total d.offres", locality)) |> 
  select(year, n_offers)

country_level_data <- full_join(country_level, offers_country) |> 
  select(year, locality, n_offers, everything()) |> 
  mutate(locality = "Grand-Duchy of Luxembourg")


# scrape a list of communes from Luxembourg


# current_communes <- "https://is.gd/lux_communes" |> 
#   rvest::read_html() |> 
#   rvest::html_table() |> 
#   purrr::pluck(2) |> 
#   janitor::clean_names() |> 
#   dplyr::filter(name_2 != 'Name') |> 
#   dplyr::rename(commune = name_2) |> 
#   dplyr::mutate(commune = stringr::str_remove(commune, " .$"))

current_communes <- "https://www.is.gd/lux_communes" |> 
  rvest::read_html() |> 
  rvest::html_table() |> 
  purrr::pluck(2) |> 
  janitor::clean_names() |> 
  dplyr::filter(name_2 != 'Name') |> 
  dplyr::rename(commune = name_2) |> 
  dplyr::mutate(commune = stringr::str_remove(commune, " .$"))


saveRDS(current_communes, 'current_communes.Rds')

#lets see if we have all the communes in our data

setdiff(unique(commune_level_data$locality), current_communes$commune)


former_communes <- "https://www.is.gd/lux_former_communes" |> 
  rvest::read_html() |> 
  rvest::html_table() |> 
  purrr::pluck(3) |> 
  janitor::clean_names() |> 
  dplyr::filter(year_dissolved > 2009)

former_communes

communes <- unique(c(former_communes$name, current_communes$commune))

#rename some communes

communes[which(communes == 'Clemency')] <- "Clémency"
communes[which(communes == 'Redange')] <- "Redange-sur-Attert"
communes[which(communes == 'Erpeldange-sur-Sûre')] <- "Erpeldange"
communes[which(communes == 'Luxembourg City')] <- "Luxembourg"
communes[which(communes == 'Käerjeng')] <- "Kaerjeng"
communes[which(communes == 'Petange')] <- "Pétange"


setdiff(unique(commune_level_data$locality), communes)

write.csv(commune_level_data, "datasets/commune_level_data.csv", row.names = TRUE)
write.csv(country_level_data, "datasets/country_level_data.csv", row.names = TRUE)

