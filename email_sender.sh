#!/bin/bash

nombre=$2
correo=$1

python3 <<EOF
import os
from email.message import EmailMessage
import ssl
import smtplib

email_sender = "ejemplo@gmail.com"
email_reciever = "$correo"
password = "ejemplo"


subject = "Ejemplo"
body = """
  esto es un Ejemplo
"""


em = EmailMessage()
em["From"] = email_sender
em["To"] = email_reciever
em["Subject"] = subject
em.set_content(body)

context = ssl.create_default_context()

with smtplib.SMTP_SSL("smtp.gmail.com",465,context = context) as smtp:
  smtp.login(email_sender,password)
  smtp.sendmail(email_sender,email_reciever,em.as_string())
EOF

exit 0
