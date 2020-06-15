---
title: GitHub
---

In order to integrate with Github.com you'll need to create an OAuth App which
will enable your CodeStream On-Prem server to use the Github REST APIs.

## Login to GitHub and Navigate to OAuth Apps

First [Login to GitHub](https://github.com), then go to your Settings page:

<img src="../assets/images/issue/github/01 Settings.png" width=150px><br>

Then select **Developer Settings**

<img src="../assets/images/issue/github/02 Dev Settings.png" width=150px><br>

And finally **OAuth Apps**

![oauth apps](../assets/images/issue/github/03 New OAuth App.png)


## Register a new OAuth App

Press the **New OAuth App** button and complete the registeration form. Make
sure your callback URL references your company's CodeStream On-Prem hostname with
this path:
`https://codestream-onprem.mycompany.com/no-auth/provider-token/github`

<!-- <img src="../assets/images/issue/github/04 Register New OAuth App.png" width=600px><br> -->
![new app](../assets/images/issue/github/04 Register New OAuth App.png)

Then press the **Register application** button.


## Update the CodeStream Config and Restart

After you register the application, click on it to expose the client ID and
client secret.

![clientID and Secret](../assets/images/issue/github/05 Client ID and Secret.png)

Then update your codestream config file,
**~/.codestream/codestream-services-config.json**, by adding the following
section.

```
	"integrations": {
		"github": {
			"cloud": {
				"appClientId": "-- Client ID goes here --",
				"appClientSecret": "-- Client Secret goes here --"
			}
		},
		...
	},
	...
```

After you make that change, restart CodeStream
```
~/.codestream/codestream --restart
```

Instruct your users to _Reload_ their IDEs. They should now be able to connect
to Github.
