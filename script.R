library(tidyverse)
library(readr)
library(lubridate)

# https://github.com/Z3tt/TidyTuesday/tree/master/plots/2020_31
# https://github.com/z3tt/TidyTuesday/blob/master/R/2020_31_PalmerPenguins.Rmd

data <- read_csv("data/data.csv") %>%
    mutate(Month=month(mdy(Date)), Year=year(mdy(Date))) %>%
    filter(Tag1 != "COMPTE") %>%
    filter(Price > -5000)

agg_month <- data %>%
    group_by(Year, Month, Tag1) %>%
    summarise(sum_price=sum(Price))


ggplot(agg_month %>% filter(),aes(x=sum_price, y=Tag1) ) + stat_halfeye() + coord_cartesian(clip = "off")