---
title: Outbound Email
description: Configure the outbound email service
---

CodeStream generates email for invitiations, notifications and more. The
outbound email service processes email requests, composes the content and
headers and passes it to your chosen email delivery service for sending. Since
you need to confirm your email address as part of the registration process, the
outbound email service is a requirement for running CodeStream On-Prem.

CodeStream supports two email sending engines; standard SMTP servers using the
npm [NodeMailer](https://www.npmjs.com/package/nodemailer) library or
[Sendgrid](https://sendgrid.com), a 3rd party cloud-based emailing service. You
must configure one.

## Sendgrid
For Sendgrid, you will need an account on their system. They are a pay service
but prices are reasonable. They offer reliability and excellent reporting and
troubleshooting. If you require that 100% of your installation operates on your
wires this will not be an option for you.

To use sendgrid:

1. Login to your sendgrid account on the web and [generate an API
   key](https://app.sendgrid.com/settings/api_keys)

2. Update your **~/.codestream/codestream-services-config.json** file to include
   this section.
	```
	"emailDeliveryService": {
		"sendgrid": {
			"apiKey": "your-sendgrid-api-key",
			"url": "/v3/mail/send"
		}
	}
	```

## SMTP Servers via NodeMailer

NodeMailer provides a simple SMTP interface for delivering email. NodeMailer
should work with any SMTP compliant mail server using standard email protocols.
We've documented a few configurations below to get you started. Typically, you'd
work with your Email Administrator to find the correct settings for your
installation.

### Sending Email via a GMail/G-Suite account

G-Mail/G-Suite allows you to send email from your account through 3rd party
software as long as you have account credentials and you configure the _enable
less secure apps_ option within your account. _It's worth noting that Google has
since end-of-lifed this feature but they have not but an expiration date to it._

1. [Follow these instructions to enable less secure apps to send email using
   your Google account](https://support.google.com/accounts/answer/6010255)

2. Update your **~/.codestream/codestream-services-config.json** file to include this section.
	```
	"emailDeliveryService": {
		"NodeMailer": {
			"host": "smtp.gmail.com",
			"password": "<my-password>",        // Your GMail or G-Suite password (in plain text!!)
			"port": "587",
			"secure": true,
			"service": "gmail",
			"username": "<my-user@gmail.com>",  // Your GMail or G-Suite email address
		}
	}
	```

### Sending Email via an SMTP relay server

Use this option if your Email Adminstrator can provide an SMTP relay server
enabled to accept email from your CodeStream host OS.

Update your **~/.codestream/codestream-services-config.json** file to include
one of these sections:

For secure SMTP traffic:
```
"emailDeliveryService": {
	"NodeMailer": {
		"host": "<your.relay.server.com>",
		"port": "587",
		"secure": true
	}
}
```

For insecure SMTP traffic:
```
"emailDeliveryService": {
	"NodeMailer": {
		"host": "<your.relay.server.com>",
		"port": "25",
		"secure": false
	}
}
```
