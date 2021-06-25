library(tidyverse)
library(readr)
library(lubridate)
library(ggdist)
library(cowplot)
library(ggtext)
library(glue)

source(file="src/plot.R")
# https://github.com/Z3tt/TidyTuesday/tree/master/plots/2020_31
# https://github.com/z3tt/TidyTuesday/blob/master/R/2020_31_PalmerPenguins.Rmd
# https://stackoverflow.com/questions/15720545/use-stat-summary-to-annotate-plot-with-number-of-observations
# https://evamaerey.github.io/ggplot2_grammar_guide/geoms_continuous_distribution.html#51
# https://evamaerey.github.io/ggplot2_grammar_guide/geoms_continuous_distribution.html#53
# https://evamaerey.github.io/ggplot2_grammar_guide/geoms_continuous_distribution.html#64
# https://stackoverflow.com/questions/15720545/use-stat-summary-to-annotate-plot-with-number-of-observations
# https://evamaerey.github.io/ggplot2_grammar_guide/geoms_discrete_discrete.html#31


data <- read_csv("data/data.csv") %>%
    mutate(Month=month(dmy(Date), label=TRUE), Year=year(dmy(Date)), YearMonth=format(dmy(Date), "%Y-%m")) %>%
    filter(Tag1 != "COMPTE") %>%
    filter(Price > -5000)

agg_month <- data %>%
    group_by(YearMonth, Tag1) %>%
    summarise(sum_price=sum(Price)) %>%
    ungroup()
# ggplot(agg_month %>% filter(),aes(x=sum_price, y=Tag1) ) + stat_halfeye() + coord_cartesian(clip = "off")



agg_month_expense_daily <- agg_month %>%
    filter(!(Tag1 %in% c("RESOURCE", "VACANCE"))) %>%
    filter(sum_price < 0) %>%
    mutate(sum_price=ifelse(Tag1=="EPARGNE", -sum_price, sum_price))

ggplot(agg_month_expense_daily, aes(x=sum_price, y=YearMonth, fill=reorder(Tag1, sum_price))) +
    geom_bar(stat="identity") + 
    geom_point(data=agg_month %>% filter(Tag1 == "RESOURCE"), aes(x=sum_price, y=YearMonth), shape=18, size=3) +
    geom_text(data=agg_month %>% filter(Tag1 == "RESOURCE"), aes(x=sum_price, y=YearMonth, label=paste0(sum_price, "€")), hjust=-0.2) +
    scale_x_continuous(breaks=c(-5000, -2500, -1250, -1000, -750, -500, -250, -100, 0, 100, 250, 500, 750, 1000, 1250, 2500)) +
    labs(title="Monthly expenses",y="", x="", fill="Categories") + 
    custom_theme() 


agg_month_expenses <- agg_month %>% 
    mutate(sum_price = ifelse(sum_price < 0, -sum_price, sum_price))

expenses_filtered <- agg_month_expenses %>%
    filter(YearMonth == "2021-05")
    

ggplot(expenses_filtered) + geom_bar(aes(x=sum_price, y=reorder(Tag1, sum_price), fill=Tag1), stat="identity") + 
    scale_x_reverse() +
    geom_point(aes(x=sum_price, y=reorder(Tag1, sum_price)), shape=18, size=3) +
    geom_text(aes(x=sum_price, y=reorder(Tag1, sum_price), label=paste0(sum_price, "€")), hjust=1.3) +
    coord_cartesian(clip = "off") +
    custom_theme()


ggplot(data) + 
    geom_dots(aes(x=Price, y=Tag1, color=Tag1, fill=Tag1), size=1, stackratio=1, binwidth=1) +
    gghighlight(YearMonth == "2021-05") +
    custom_theme() + 
    coord_cartesian(xlim=c(-100,100))

