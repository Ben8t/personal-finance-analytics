library(tidyverse)
library(readr)
library(lubridate)
library(ggdist)
library(cowplot)
library(ggtext)
library(glue)

source(file="src/plot.R")

data <- read_csv("data/data.csv") %>%
    mutate(Month=month(dmy(Date), label=TRUE), Year=year(dmy(Date)), YearMonth=format(dmy(Date), "%Y-%m")) %>%
    filter(Tag1 != "COMPTE") %>%
    filter(Price > -5000)


FILTER_MONTH <- "2021-05"
PARSED_FILTER_DATE <- parse_date_time(FILTER_MONTH, "ym")
FILTER_MONTH_LABEL <- glue("{month(ymd(PARSED_FILTER_DATE), label=TRUE, abbr=FALSE)} {year(ymd(PARSED_FILTER_DATE))}")

plot_data <- data %>% group_by(YearMonth, Tag1) %>% summarise(sum_price=sum(Price))
total_expense <- plot_data %>% filter(YearMonth==FILTER_MONTH) %>% filter(!(Tag1 %in% c("EPARGNE", "RESOURCE"))) %>% pull(sum_price) %>% sum()

expense_plot <- ggplot(data=plot_data) + 
    geom_dots(aes(x=sum_price, y=reorder(Tag1, -sum_price), alpha=YearMonth), size=2.5, stackratio=5, binwidth=1, color="grey") +
    stat_summary(aes(x=sum_price, y=Tag1), fun="median", fun.min=min, fun.max=max, color="grey", shape=18, size=0.5, position=position_nudge(y=-0.1)) +
    geom_text(data=. %>% ungroup() %>% group_by(Tag1) %>% summarise(mean_price=median(sum_price)) %>% ungroup(), aes(x=mean_price, y=Tag1, label=paste0(round(mean_price, digits=0), "€")), size=3, position=position_nudge(y=-0.3), color="grey") +
    geom_text(data=. %>% ungroup() %>% group_by(Tag1) %>% summarise(min_price=min(sum_price)) %>% ungroup(), aes(x=min_price, y=Tag1, label=paste0(Tag1), color=Tag1), size=3, nudge_x=-500, fontface="bold") +
    geom_dots(data=. %>% filter(YearMonth==FILTER_MONTH), aes(x=sum_price, y=Tag1, color=Tag1, fill=Tag1), size=2.5, stackratio=5, binwidth=1) +
    geom_label(data=.%>% filter(YearMonth==FILTER_MONTH), aes(x=sum_price, y=Tag1, label=paste0(round(sum_price, digits=0), "€"), color=Tag1), nudge_y=0.3, size=3) +
    scale_x_continuous(breaks=c(-2500, -1250, -1000, -750, -500, -250, 0, 250, 500, 750, 1000, 1250, 2500)) +
    labs(
        title=glue("<img src='misc/emoji.png' width='20'/> Monthly expenses {FILTER_MONTH_LABEL}"), 
        subtitle=glue("Total expenses<sup>1</sup> : {total_expense} €"), 
        x="€", y="", fill="", color="") +
    theme(legend.position="none") +
    annotate(
        geom="text",  
        x=-4000, y=1,  
        label="1: all expenses without EPARGNE and RESOURCE tags.\n Note : some high outliers have been removed.",  
        hjust=1, size=2.5, fontface="italic", color="grey") +
    coord_cartesian(clip="off") +
    custom_theme()


legend_data <- tibble(sum_price=c(-280, -275, -200, -103, -450, -35, 54, 12), Tag1="CATEGORY") %>%
    mutate(YearMonth=ifelse(sum_price==-200, "MONTH", "OTHERS"))

legend_plot <- ggplot(legend_data) + 
    geom_dots(aes(x=sum_price, y=Tag1, fill=Tag1), size=2.5, stackratio=5, binwidth=1, color="grey") +
    stat_summary(aes(x=sum_price, y=Tag1), fun="median", fun.min=min, fun.max=max, color="grey", shape=18, size=0.5, position=position_nudge(y=-0.01)) +
    geom_text(data=. %>% ungroup() %>% group_by(Tag1) %>% summarise(mean_price=median(sum_price)) %>% ungroup(), aes(x=mean_price, y=Tag1, label=paste0(round(mean_price, digits=0), "€")), size=3, position=position_nudge(y=-0.05), color="grey") +
    geom_dots(data=. %>% filter(YearMonth=="MONTH"), aes(x=sum_price, y=Tag1, color=Tag1, fill=Tag1), size=2.5, stackratio=5, binwidth=1) +
    geom_label(data=. %>% filter(YearMonth=="MONTH"), aes(x=sum_price, y=Tag1, label=paste0(round(sum_price, digits=0), "€"), color=Tag1), nudge_y=0.05, size=3) +
    annotate(x=-425, y=1.1, label="Month expense", geom="text", color="grey", size=3) +
    annotate(geom="curve", curvature= -.3, x=-320, xend=-205, y=1.1, yend=1.08, arrow=arrow(length=unit(0.2,"cm"), type="closed"), color="grey") +
    annotate(x=20, y=0.902, label="Overall median", geom="text", color="grey", size=3) +
    annotate(geom="curve", curvature= -.3, x=-80, xend=-145, y=0.9, yend=0.925, arrow=arrow(length=unit(0.2,"cm"), type="closed"), color="grey") +
    theme_void() +
    coord_cartesian(clip="off") +
    theme(legend.position="none")

main_plot <- ggdraw() + draw_plot(expense_plot) + draw_plot(legend_plot, x=0.08, y=-0.1, width=0.2)
main_plot + ggsave(glue("img/monthly-expense-{FILTER_MONTH}.png"), bg="white", width=32, height=25, units="cm", dpi=300)