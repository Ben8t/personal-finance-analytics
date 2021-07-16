import base64
import os
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

template = read_template("email/template.html")
rendered_template = template.render(date_title="July 2021")

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
