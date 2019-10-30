# CodeStream On-Prem Outbound Email Setup

CodeStream supports one of two mail sending engines; the
[sendgrid](https://sendgrid.com) service and the npm
[NodeMailer](https://www.npmjs.com/package/nodemailer) library. NodeMailer, in
turn, can be configured for a number of different scenarios.

Quick Links
* [SendGrid](#sendgrid)
* [NodeMailer Using GMail/G-Suite](#nodemailer-submitting-email-via-a-gmailg-suite-account)
* [NodeMailer Using Custom Mail Relay Server](#nodemailer-using-a-mail-relay-which-accepts-mail-from-codestream-on-prem)

## Sendgrid
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

## NodeMailer submitting Email via a GMail/G-Suite account

GMail/G-Suite allows you to send email from your account through 3rd party
software as long as you have the account credentials and you configure it to
enable less secure apps to do so.
   
1. [Follow these instructions to enable less secure apps to send email
   using your account](https://support.google.com/accounts/answer/6010255)

2. Update your **~/.codestream/codestream-services-config.json** file to include
   this section.
	```
	"emailDeliveryService": {
		"NodeMailer": {
			"host": "smtp.gmail.com",
			"emailTo": "all-mail-diverts-to@somewhere.com",  // (optional) if you want all mail diverted to a single address, enter it here (optional)
			"password": "my-password",        // (required) Your GMail or G-Suite account password (in plain text!!)
			"port": "587",
			"secure": true,
			"service": "gmail",
			"username": "my-user@gmail.com",  // (required) Your GMail or G-Suite account email address
		}
	}
	```

## NodeMailer using a mail-relay which accepts mail from CodeStream on-prem

Assuming you can setup a mail-relay server (or modify an existing one) so that
it accepts email from your CodeStream On-Prem host OS, you can configure
NodeMailer to use that.

1. Configure your mail-relay server. Identify its host name and the port it will
   accept mail on. Also determine if the relay accepts secure (encrypted)
   traffic.

2. Update your **~/.codestream/codestream-services-config.json** file to include
   this section.
	```
	"emailDeliveryService": {
		"NodeMailer": {
			"host": "your.relay.server.com",
			"emailTo": "all-mail-diverts-to@somewhere.com",  // (optional) if you want all mail diverted to a single address, enter it here (optional)
			"port": "587",
			"secure": true
		}
	}
	```
