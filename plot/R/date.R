library(lubridate)

find_last_month_year <- function(){
    return(format(ymd(today()), "%Y-%m"))
}