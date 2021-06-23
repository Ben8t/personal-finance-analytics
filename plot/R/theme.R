
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
      plot.title=element_textbox(size=18),
      plot.subtitle=element_textbox()
    ),
    theme(text=element_text(family="Object Sans", face="bold", size=8))
  )
}