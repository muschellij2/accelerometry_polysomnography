library(GENEAread)
library(dplyr)
library(readr)
library(lubridate)
library(tibble)
library(hms)
read_binfile = function(binfile) {
  res = GENEAread::read.bin(binfile)
  id = sub(".*MECSLEEP(\\d*)_.*", "\\1", binfile)
  wrist = sub(".*MECSLEEP\\d*_(.* wrist).*", "\\1", binfile)
  wrist = tolower(wrist)
  start_time = gsub(".*_(.*)[.]bin", "\\1", basename(binfile))
  data = res$data.out
  x = header.info(binfile, more = TRUE)
  hdr = as.list(x$Value)
  names(hdr) = rownames(x)
  hdr$Device_Location_Code = tolower(hdr$Device_Location_Code)
  stopifnot(hdr$Device_Location_Code == wrist)
  res$data.out = NULL
  data = tibble::as_tibble(data)
  data$timestamp = as.POSIXct(data$timestamp, tz = "UTC",
                              origin = "1970-01-01")
  start_time = res$header$Value[[4]]
  start_time = sub("(.*):(\\d{3})", "\\1.\\2", start_time)
  start_time = lubridate::as_datetime(start_time)
  stopifnot(abs(data$timestamp[1] - start_time) < 0.99)
  
  data = data[, c("timestamp", "x", "y", "z")]
  data$acc = sqrt(data$x^2 + data$y^2 + data$z^2) - 1
  return(data)
}

# txt = "dataset_psgnewcastle2015_v1.0/psg/mecsleep01_psg.txt"
read_psg = function(txt) {
  x = readLines(txt)
  x = head(x, 17)
  date = x[ grepl("(d|D)ate", x)]
  date = sub(".*\t", "", date)
  date = dmy(date)
  data = readr::read_tsv(txt, skip = 17)
  if (!"Position" %in% colnames(data)) {
    warning(paste0(txt, " has no position variable"))
    data$Position = NA
  }
  data = data %>% 
    rename(time = `Time [hh:mm:ss]`,
           duration = `Duration[s]`,
           sleep_stage = `Sleep Stage`,
           position = Position,
           event = Event) %>% 
    mutate(position = ifelse(position == "N/A", NA, position))
  stopifnot(is_hms(data$time))
  data$datetime = lubridate::ymd_hms(
    paste(date, as.character(data$time)))
  return(data)
}
