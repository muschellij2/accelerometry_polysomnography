rm(list=ls())
library(GENEAread)
library(dplyr)
library(readr)
library(lubridate)
setwd(here::here())
pinfo = readr::read_csv(
  here::here("participants_info.csv"))
bin_files = list.files(
  path = "acc", 
  pattern = "[.]bin(.gz|)$",
  recursive = TRUE, 
  full.names = TRUE)
df = tibble::tibble(
  bin = bin_files)


df$weight = df$height = df$sex = df$handedness = NA
df$location = NA
df$dob = lubridate::ymd("adsf")
df$id = basename(df$bin)
df$id = sub("MECSLEEP(\\d*)_.*", "\\1", df$id)

missing_to_na = function(x) {
  x[x %in% ""] = NA
  x
}

i = 1
for (i in seq(nrow(df))) {
  print(i)
  binfile = df$bin[i]
  x = header.info(binfile, more = TRUE)
  wrist = sub(".*MECSLEEP\\d*_(.* wrist).*", "\\1", binfile)
  wrist = tolower(wrist)
  
  hdr = as.list(x$Value)
  names(hdr) = rownames(x)
  hdr$Device_Location_Code = tolower(hdr$Device_Location_Code)
  stopifnot(hdr$Device_Location_Code == wrist)
  
  df$dob[i] = lubridate::ymd(hdr$Date_of_Birth)
  df$sex[i] = missing_to_na(hdr$Sex)
  df$handedness[i] = missing_to_na(hdr$Handedness_Code)
  df$weight[i] = as.numeric(hdr$Weight)
  df$height[i] = as.numeric(hdr$Height)
  df$location[i] = wrist
}

df = df %>% 
  select(-bin) %>% 
  group_by(id) %>% 
  mutate(
    handedness = zoo::na.locf(handedness, na.rm = FALSE),
    height = zoo::na.locf(height, na.rm = FALSE),
    weight = zoo::na.locf(weight, na.rm = FALSE)) %>% 
  ungroup() %>% 
  select(-location) %>% 
  distinct() %>% 
  mutate(id = as.numeric(id)) %>% 
  arrange(id) 
df = full_join(df, pinfo)
stopifnot(all(df$sex == df$Sex, na.rm = TRUE))

df = df %>% 
  select(-sex, -dob)
# readr::write_csv(df)
