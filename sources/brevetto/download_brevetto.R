library(dplyr)
library(rvest)

file <- "/Users/tommasobertola/Git/TrainingPerformances/list_url_salite.txt"
url <- readLines(file)
for (i in 1:length(url)) {
    gpx_track <- read_html(url[i]) %>%
        html_nodes(xpath = "//a[@target='_blank']") %>%
        html_attr("href") %>%
        as.data.frame() %>%
        filter(endsWith(., ".gpx")) %>%
        tail(1) %>%
        unlist() %>%
        as.character()
    download.file(gpx_track, destfile = paste0("/Users/tommasobertola/Git/TrainingPerformances/data/routes/", basename(gpx_track)))
    cat("\r", i, "of", length(url))
}
