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
csv_outfiles = sub("[.]bin.*", ".csv", basename(bin_files))
df = tibble::tibble(
  bin = bin_files,
  csv = csv_outfiles,
  gz_csv = paste0(csv, ".gz"))
df = df %>% 
  filter(!file.exists(gz_csv))


df$weight = df$height = df$sex = df$handedness = NA
df$location = NA
df$dob = lubridate::ymd("adsf")

i = 1
binfile = df$bin[i]
outfile = df$csv[i]
# write_out_csv = function(binfile) {
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

data$acc = sqrt(data$x^2 + data$y^2 + data$z^2) - 1


df$dob[i] = lubridate::ymd(hdr$Date_of_Birth)
df$sex[i] = hdr$Sex
df$handedness[i] = hdr$Handedness_Code
df$weight[i] = as.numeric(hdr$Weight)
df$height[i] = as.numeric(hdr$Height)
df$location[i] = wrist
write_csv(x = data, path = outfile)
R.utils::gzip(outfile, compression = 9)
# }
