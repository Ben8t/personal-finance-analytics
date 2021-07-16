import base64
import os
from mailjet_rest import Client


MAILJET_USER = os.environ.get("MAILJET_USER")
MAILJET_CREDENTIAL = os.environ.get("MAILJET_CREDENTIAL")

mailjet_client = Client(auth=(MAILJET_USER, MAILJET_CREDENTIAL), version='v3.1')


with open("plot/img/monthly-expense-2021-07.png", "rb") as image_file:
    image_encoded = base64.b64encode(image_file.read())
    image_content = image_encoded.decode('utf-8') 

with open("email/template.html", "r") as fopen:
    html_template = str(fopen.read())

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
            "HTMLPart": html_template,
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
