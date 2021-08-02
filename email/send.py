import argparse
import base64
import datetime
from dateutil.relativedelta import relativedelta
import logging
import os
import random
from jinja2 import Template
from mailjet_rest import Client


def read_template(template_file: str) -> Template:
    with open(template_file, "r") as template_open:
        return Template(template_open.read())


MAILJET_API_KEY = os.environ.get("MAILJET_API_KEY")
MAILJET_API_SECRET = os.environ.get("MAILJET_API_SECRET")


if __name__ == "__main__":
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)
    logger.addHandler(logging.StreamHandler())

    parser = argparse.ArgumentParser(description='Email sending for personal finance analytics')
    parser.add_argument('--reminder', default=False, action='store_true')
    args = parser.parse_args()

    mailjet_client = Client(auth=(MAILJET_API_KEY, MAILJET_API_SECRET), version='v3.1')

    date = datetime.datetime.today()
    date_minus_one_month = date - relativedelta(months=1)
    month_year_date = date_minus_one_month.strftime("%Y-%m")

    quotes = ["I'm not in the casino industry, but I am in the fire service: Casinos pump an extra 1% of oxygen into the air to make you more alert and give you more energy. You stay longer and spend more money. It's also why casino fires are so catastrophic.", "A problem that can be solved with money is not really a problem.", "To be wealthy, accumulate all those things that money can’t buy.", "Don’t create things to make money; make money so you can create things. The reward for good work is more work.", "“What do you do with your money?” My answer at the time was “Nothing, really.” Okay, so why try so hard to earn lots more of it?"]

    user_name = "Benoit"
    user_email = "pimpaudben@gmail.com"
    quote = random.choice(quotes)
    date_title = date.strftime("%B %Y")

    if args.reminder:
        template = read_template("email/reminder.html")
        rendered_template = template.render(user_name=user_name, date_title=date_title, quote=quote)
        subject = f"Personal Finance Analytics - Reminder {date_title}"
        data = {
            "Messages": [
                {
                    "From": {
                        "Email": "pimpaudben@gmail.com",
                        "Name": "Personal Finance Analytics"
                    },
                    "To": [
                        {
                            "Email": user_email,
                            "Name": user_name
                        }
                    ],
                    "Subject": subject,
                    "HTMLPart": rendered_template
                }
            ]
        }
    else:
        template = read_template("email/template.html")
        rendered_template = template.render(user_name=user_name, date_title=date_title, quote=quote)
        subject = f"Personal Finance Analytics - {date_title}"
        with open(f"plot/img/monthly-expense-{month_year_date}.png", "rb") as image_file:
            image_encoded = base64.b64encode(image_file.read())
            image_content = image_encoded.decode('utf-8') 
            data = {
                "Messages": [
                    {
                        "From": {
                            "Email": "pimpaudben@gmail.com",
                            "Name": "Personal Finance Analytics"
                        },
                        "To": [
                            {
                                "Email": user_email,
                                "Name": user_name
                            }
                        ],
                        "Subject": subject,
                        "HTMLPart": rendered_template,
                        "InlinedAttachments": [
                            {
                                "ContentType": "image/png",
                                "Filename": f"monthly-expense-{month_year_date}.png",
                                "ContentID": "id1",
                                "Base64Content": f"{image_content}"
                            }
                        ]
                    }
                ]
            }



    result = mailjet_client.send.create(data=data)
    logger.info(result.status_code)
    logger.info(result.json())
