import base64
import os
import random
from jinja2 import Template
from mailjet_rest import Client


def read_template(template_file: str) -> Template:
    with open(template_file, "r") as template_open:
        return Template(template_open.read())

MAILJET_API_KEY = os.environ.get("MAILJET_API_KEY")
MAILJET_API_SECRET = os.environ.get("MAILJET_API_SECRET")

mailjet_client = Client(auth=(MAILJET_API_KEY, MAILJET_API_SECRET), version='v3.1')


with open("plot/img/monthly-expense-2021-07.png", "rb") as image_file:
    image_encoded = base64.b64encode(image_file.read())
    image_content = image_encoded.decode('utf-8') 

quotes = ["I'm not in the casino industry, but I am in the fire service: Casinos pump an extra 1% of oxygen into the air to make you more alert and give you more energy. You stay longer and spend more money. It's also why casino fires are so catastrophic.", "A problem that can be solved with money is not really a problem.", "To be wealthy, accumulate all those things that money can’t buy.", "Don’t create things to make money; make money so you can create things. The reward for good work is more work.", "“What do you do with your money?” My answer at the time was “Nothing, really.” Okay, so why try so hard to earn lots more of it?"]
quote = random.choice(quotes)

template = read_template("email/template.html")
rendered_template = template.render(date_title="July 2021", quote=quote)

data = {
    "Messages": [
        {
            "From": {
                "Email": "download100mph@gmail.com",
                "Name": "Toto"
            },
            "To": [
                {
                    "Email": "download100mph@gmail.com",
                    "Name": "Toto"
                }
            ],
            "Subject": "Hello",
            "HTMLPart": rendered_template,
            "InlinedAttachments": [
                  {
                      "ContentType": "image/jpeg",
                      "Filename": "toto.jpeg",
                      "ContentID": "id1",
                      "Base64Content": f"{image_content}"
                  }
            ]
        }
    ]
}


result = mailjet_client.send.create(data=data)
