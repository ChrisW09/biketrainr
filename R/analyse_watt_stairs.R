library(xts)
library(dygraphs)

source("R/gen_energy_data.R")
source("R/load_from_strava.R")

file_name <- "C:/Users/User11/Downloads/Morga.fit"
file_name <- "C:/Users/User11/Downloads" %>%
  {file.path(., list.files(.))} %>%
  file.info() %>%
  {rownames(.[which.max(.$atime), ])}


intervall_file_names <- "C:/Users/User11/Downloads" %>%
  {file.path(., list.files(.))} %>%
  .[grepl(., pattern = ".fit")] %>%
  .[grepl(., pattern = "4_4|Intervall|Wahoo")]

intervall_file_names

baseline = c(79, 111, 121, 129, 139, 150, 154)
watts <- c(0, 100, 130, 160, 190, 220, 230)

hrs_list <- list()
file_name <- intervall_file_names[1]
for(nr in seq(intervall_file_names)){

  file_name <- intervall_file_names[nr]
  records <- load_strava(file_name)

  plot(records$power)
  idx <- 7
  hrs <- sapply(seq(watts), function(idx){
    cand <- which(abs(records$power - watts[idx]) < 5)
    cc <- cand[cand < idx*3*60]

    start <- ceiling(length(cc)/2)
    idxs <- cc[start:length(cc)]
    if(length(idxs) < 30) return(NA)
    mean(records$heart_rate[idxs], na.rm = TRUE)
  })

  date <- records$timestamp[1] %>% as.Date()
  print(date)
  hrs_list[[nr]] <- hrs
  names(hrs_list)[nr] <- date
}

ord <- names(hrs_list) %>% as.numeric() %>%  as.Date() %>% order

hr <- hrs_list[ord] %>% do.call(rbind, .)
colnames(hr) <- c(0, 100, 130, 160, 190, 220, 230)
hr <- data.frame(hr)
hr$time <- rownames(hr) %>% as.numeric %>% as.Date()

qxts <- xts(hr[, 1:7], order.by = hr$time)
dygraph(qxts)



