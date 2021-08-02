library(lubridate)

find_last_month_year <- function(){
    date_minus_month <- add_with_rollback(ymd(today), months(-1))
    return(format(date_minus_month, "%Y-%m"))
}
