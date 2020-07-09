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
[Sendgrid](https://sendgrid.com), a 3rd party cloud-based emailing service.

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

## GMail/G-Suite SMTP Relay (via NodeMailer)

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

## Generic SMTP relay server (via NodeMailer)

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

## Amazon SES with SMTP (via NodeMailer)

Amazon's Simple Email Service can be configured to accept email via the SMTP
protocol (in addition to the SES APIs). Below is a quick reference which should
get you started. That said, SES does have quite a few configuration options and
it is beyond the scope of this guide to document them.

[This is the entry page to configuring SES for
SMTP.](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-smtp.html)

1. [Choose your end point (which is region specific) and
    port.](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-connect.html)
    For this example, we'll use TLS which uses port **465**.

1. [Configure an IAM user to allow submission of
    email.](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-credentials.html)
    When you follow the instructions you will get an AWS Access Key and email
    password. _Do not confuse the email password with the AWS Secret. They are
    different._  The IAM user requires the managed **AmazonSesSendingAccess**
    policy or similar:
	```
	"Statement": [
		{
			"Effect": "Allow",
			"Action":
			"ses:SendRawEmail",
			"Resource":"*"
		}
	]
	```

1. [Choose the sending email address you want to use and verify it with
   SES.](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-email-addresses-procedure.html)
   SES will send an email to it with a link you must confirm.

1. Update your **~/.codestream/codestream-services-config.json** config file
   with all of the data you setup and gathered.

    ```
    {
        "apiServer": {
            "confirmationNotRequired": false,
			...
        },
        ...
        "email": {
            "senderEmail": "sending-email-address@mydomain.com",
            ...
            "suppressEmails": false,
            ...
        },
        ...
        "emailDeliveryService": {
            "NodeMailer": {
                "host": "<region-specific-SES-endpoint>",
                "password": "<SES-user-password>",
                "port": 465,
                "secure": true,
                "service": null,
                "username": "<SES-user-access-key>"
            }
        },
        ...
    }
    ```

1. Once you've saved the config file, restart codestream for it to take effect
   (`~/.codestream/codestream --restart`).