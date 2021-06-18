library(tidyverse)
library(readr)
library(lubridate)

# https://github.com/Z3tt/TidyTuesday/tree/master/plots/2020_31
# https://github.com/z3tt/TidyTuesday/blob/master/R/2020_31_PalmerPenguins.Rmd

custom_theme <- function(){
  list(
    theme(plot.margin=unit(c(1,2,1,1), "cm")),
    theme(
      panel.grid.minor=element_line(color="#DCDCDC"),
      panel.grid.major=element_line(color="#DCDCDC"),
      panel.border=element_blank(),
      panel.background=element_blank(),
      axis.ticks=element_line(),
      axis.line.x=element_line(size=0.2, linetype="solid", colour="black"),
      axis.line.y=element_line(size=0.2, linetype="solid", colour="black"),
      axis.text.x=element_text(size=8, angle=45, vjust = 0.5), 
      axis.text.y=element_text(size=8),
      axis.title.x=element_text(size=10),
      axis.title.y=element_text(size=10),
      legend.title=element_text(size=10),
      legend.text=element_text(size=10),
      plot.title=element_text(size=25)
    ),
    theme(text=element_text(family="Object Sans", face="bold", size=8))
  )
}


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