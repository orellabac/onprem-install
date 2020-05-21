---
title: SSL Certificates
description: Add an SSL Certificate for secure communication
---

Using SSL Certificates is a very good idea and now that you've tasted
CodeStream, it's time to start securing it. It's also something you'll need to
do in order to make use of our integrations.

You can use either accredited certificates (those issued from a known and
accepted Certificate Authority) or your own self-signed certificates. If you
create your own, your client IDEs will need to modify their settings to allow
self-signed certificates by disabling **strict certificate checking**.

## Obtain Your SSL Certificate

As mentioned above you can purchase one from a CA or sign your own. Obtaining
one is beyond the scope of this guide. For the **Single Host Linux**
configuratoin, a certificate for a single host name is sufficient.

When you obtain your certificate you'll have 2 or 3 files.

*	A private key which you created to sign your certificate.
*	The certificate issued by the CA or self-signed.
*   An optional _certificate chain_ or _bundle_ file which contains the root and
    intermediate issuer certificates. It's often not appicable to self-signed
    certificates.

Place a copy of the files (in **PEM** format) in the **~/.codestream/** directory
on the linux host OS.

## Update the CodeStream Configuration File

*   In an editor, update your configuration file
    **~/.codestream/codestream-services-config.json** so it contains the
    following section, replacing the file name placeholders (the part enclosed
    in `<>`) with the file names of your certificate files (do not include the
    paths).
	```
	{
		"ssl": {
			"cafile": "/opt/config/<CA-file-name>",
			"certfile": "/opt/config/<CERT-file-name>",
			"keyfile": "/opt/config/<KEY-file-name>",
			"requireStrictSSL": true
		}
	}
	```
    Set `requireStrictSSL` to `false` if you are using a self-signed
    certificate.
	
	If you have a self-signed certificate, the `cafile` property is
    optional.

    Leave the **/opt/config/** path prefixes as is. They are relative to the
    docker containers.

*   Change the API and Broadcaster sections to include the following properties:
	```
	{
		"apiServer": {
			"ignoreHttps": false
			"port": 443
		},
		"broadcastEngine": {
			"codestreamBroadcaster": {
				"ignoreHttps: false,
				"port": 12443
			}
		}
	}
	```

## Restart the CodeStream Backend Services

Run this command on your host OS:
```
~/.codestream/codestream --restart
```

## Update Your CodeStream IDE Client Settings

Everyone using CodeStream will need to modify their IDE settings with the new
secure URL. Have your clients [follow the IDE-specific instructions located
here.](../ide/overview)