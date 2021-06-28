library(glue)
library(keyring)
library(blastula)
source(file="plot/R/date.R")


SMTP_USER <- Sys.getenv("SMTP_USER")
SMTP_PASSWORD <- Sys.getenv("SMTP_PASSWORD")
RECEIVER <- Sys.getenv("RECEIVER")

last_date <- find_last_month_year()

email <- compose_email(
    body=md(glue("Hello there!\nHere is your last month expenses\n![](plot/img/monthly-expense-{last_date}.png)"))
)

email %>% 
    smtp_send(
        to=RECEIVER,
        from="Personal Finance Analytics",
        subject="Monthly Expense",
        credentials=creds_envvar(
            user = SMTP_USER,
            pass_envvar = "SMTP_PASSWORD",
            provider = "gmail",
            host = NULL,
            port = NULL,
            use_ssl = TRUE
            )
    )