library(stringr)
library(rvest)
library(httr)

setwd("/Users/RaymonYue/Desktop")
process_url<-function(str){
  
  split_string<-unlist(strsplit(str,"?source=content_type"))
  return(paste("https://seekingalpha.com/",split_string[1],sep=""))
}

grab_pres_url<-function(ticker){
  url_base<-paste("https://seekingalpha.com/symbol/", ticker, "/earnings/transcripts?page=", sep="")
  ret_urls <- character(0)
  for (i in 1:8) {
    url <- paste(url_base, i, sep = "")
    webpage <- read_html(url)
    links <- html_nodes(webpage, "a")
    
    # Check if any of the keywords are present in the URL
    filtered_links1 <- links[grepl("Slide", html_text(links, trim = TRUE))]
    filtered_links2 <- links[grepl("Presentation", html_text(links, trim = TRUE))]
    
    # Extract the href attributes from the filtered links
    filtered_urls1 <- html_attr(filtered_links1, "href")
    filtered_urls2 <- html_attr(filtered_links2, "href")
    filtered_urls <- union(filtered_urls1, filtered_urls2)
    adjusted_urls <- unlist(lapply(filtered_urls, process_url))
    
    # Combine the URLs
    ret_urls <- c(ret_urls, adjusted_urls)
  }
  
  return(ret_urls)
  
}

download_for_ticker<-function(ticker){
  dir.create(ticker)
  url_list<-grab_pres_url(ticker)
  for(link in url_list){
    temp_page <- read_html(link)
    temp_page_links <- html_nodes(temp_page, "a")
    temp_dl_link <- temp_page_links[grepl("View as PDF",
                                          html_text(temp_page_links, trim = TRUE))]
    if(length(temp_dl_link)!=1){
      next
    }
    
    temp_dl_url <- html_attr(temp_dl_link, "href")
    
    local_name<-
      str_extract(link, paste0("(?<=\\Q", "article/", "\\E).*$"))
    local_name<-str_sub(local_name, start = 9, end = -2)
    local_file_path <- paste(getwd(),"/",ticker,"/",local_name,".pdf",sep="")
    print(temp_dl_url)
    download.file(temp_dl_url, local_file_path, mode = "wb")
  }
}


