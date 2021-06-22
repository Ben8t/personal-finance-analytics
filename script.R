library(tidyverse)
library(readr)
library(lubridate)
library(ggdist)
library(ggbeeswarm)

# https://github.com/Z3tt/TidyTuesday/tree/master/plots/2020_31
# https://github.com/z3tt/TidyTuesday/blob/master/R/2020_31_PalmerPenguins.Rmd
# https://stackoverflow.com/questions/15720545/use-stat-summary-to-annotate-plot-with-number-of-observations
# https://evamaerey.github.io/ggplot2_grammar_guide/geoms_continuous_distribution.html#51
# https://evamaerey.github.io/ggplot2_grammar_guide/geoms_continuous_distribution.html#53
# https://evamaerey.github.io/ggplot2_grammar_guide/geoms_continuous_distribution.html#64
# https://stackoverflow.com/questions/15720545/use-stat-summary-to-annotate-plot-with-number-of-observations
# https://evamaerey.github.io/ggplot2_grammar_guide/geoms_discrete_discrete.html#31

custom_theme <- function(){
  list(
    theme(plot.margin=unit(c(1,2,1,1), "cm")),
    theme(
      panel.grid.minor=element_blank(),
      panel.grid.major=element_line(color="#DCDCDC", linetype="dashed"),
      panel.grid.major.y=element_blank(),
      panel.border=element_blank(),
      panel.background=element_blank(),
      axis.ticks=element_line(),
      axis.line.x=element_line(size=0.2, linetype="solid", colour="black"),
      axis.line.y=element_blank(),
      axis.ticks.y=element_blank(),
      axis.text.x=element_text(size=8, angle=45, vjust = 0.5), 
      axis.text.y=element_blank(),
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


FILTER_MONTH <- "2021-04"
ggplot(data=plot_data) + 
    geom_vline(xintercept=0,linetype = "dashed", color="black") +
    geom_dots(aes(x=sum_price, y=reorder(Tag1, -sum_price)), size=2.5, stackratio=5, binwidth=1, color="#8d8d8d") +
    stat_summary(aes(x=sum_price, y=Tag1), fun="median", fun.min=min, fun.max=max, color="#8d8d8d", shape=18, size=0.5, position=position_nudge(y=-0.1)) +
    geom_text(data=. %>% ungroup() %>% group_by(Tag1) %>% summarise(mean_price=median(sum_price)) %>% ungroup(), aes(x=mean_price, y=Tag1, label=paste0(round(mean_price, digits=0), "€")), size=3, position=position_nudge(y=-0.3), color="#8d8d8d") +
    geom_text(data=. %>% ungroup() %>% group_by(Tag1) %>% summarise(min_price=min(sum_price)) %>% ungroup(), aes(x=min_price, y=Tag1, label=paste0(Tag1), color=Tag1), size=3, nudge_x=-500, fontface = "bold") +
    geom_dots(data = . %>% filter(YearMonth==FILTER_MONTH), aes(x=sum_price, y=Tag1, color=Tag1, fill=Tag1), size=2.5, stackratio=5, binwidth=1) +
    geom_label(data = .%>% filter(YearMonth==FILTER_MONTH), aes(x=sum_price, y=Tag1, label=paste0(round(sum_price, digits=0), "€"), color=Tag1), nudge_y=0.3, size=3) +
    scale_x_continuous(breaks=c(-5000, -2500, -1250, -1000, -750, -500, -250, 0, 250, 500, 750, 1000, 1250, 2500)) +
    #coord_cartesian(xlim=c(-800,800), clip="on") +
    labs(title=paste0(FILTER_MONTH, " expenses"), x="€", y="", fill="", color="") +
    theme(legend.position="none") +
    custom_theme()


