library(httr)
library(dplyr)
library(glue)

if(file.exists(".env")){
    readRenviron(".env")
}
notion_api_secret <- Sys.getenv("NOTION_API_SECRET")

if(is.null(notion_api_secret)){
    print("Error while reading NOTION_API_SECRET")
    exit()
}

notion_database_id <- "6086bc69b5494910a7e6caffdbd3cc5d"
base_url <- glue("https://api.notion.com/v1/databases/{notion_database_id}/query")


add_row_to_results <- function(result_dataframe, content_response){
    for(row in content_response$results){
        if(!is.null(row$properties$Date)){
            date <- row$properties$Date$date$start
            price <- row$properties$Price$number
            tag1 <- row$properties$Tag1$select$name
            tag2 <- row$properties$Tag2$select$name
            name <- row$properties$Name$title[[1]]$text$content
            if(is.null(tag2)){
                result_dataframe <- result_dataframe %>% add_row(Date=date, Name=name, Tag1=tag1, Price=price)
            }
            else{
                result_dataframe <- result_dataframe %>% add_row(Date=date, Name=name, Tag1=tag1, Tag2=tag2, Price=price)
            }
        }
    }
    return(result_dataframe)
}


response <- POST(
    base_url, add_headers("Authorization"=glue('Bearer {notion_api_secret}'), "Notion-Version"="2021-05-13", "Content-Type"="application/json"), 
    body = '{"page_size": 50}'
)
result_dataframe <- tibble(
  Date = character(),
  Name = character(),
  Tag1 = character(),
  Tag2 = character(),
  Price = numeric(),
)
has_more <- TRUE

while(has_more){
    content_response <- content(response)
    result_dataframe <- add_row_to_results(result_dataframe, content_response)
    print(glue("Processed {length(content(response)$results)} rows"))
    next_cursor <- content_response$next_cursor
    response <- POST(
        base_url, add_headers("Authorization"=glue('Bearer {notion_api_secret}'), "Notion-Version"="2021-05-13", "Content-Type"="application/json"), 
        body = paste0('{"start_cursor": "', next_cursor, '", "page_size": 50}')
    )
    has_more <- content(response)$has_more
    if(is.null(has_more)){
        has_more <- FALSE
    }
}

write.csv(result_dataframe, "data/data.csv", row.names=FALSE)