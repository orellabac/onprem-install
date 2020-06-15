---
title: Azure DevOps
---

Integration with Azure DevOps requires an App to supply credentials for
accessing the Microsoft DevOps REST API. As an Admin, you'll create this App and
add its credentials to the CodeStream On-Prem configuration file. When a
CodeStream user connects to Azure DevOps, they'll provide a DevOps oragnization
and authorize this app for it.


## Login to Azure DevOps and Register an App

[Login to Azure DevOps](https://devops.azure.com). Once logged in, click on this
link to [register a new app](https://app.vsaex.visualstudio.com/app/register).

![create rest api app](../assets/images/issue/azuredevops/02 Create App.png)

Complete all the required fields. Make sure the **Identity (read)** and **Work
Items (read and write)** scopes are checked. _NOTE: You cannot change the scopes
once the app is registered._ Make sure your callback URL matches your CodeStream
On-Prem hostname with this path:
`https://codestream-onprem.mycompany.com/no-auth/provider-token/azuredevops`.
Once the form is complete, Click the **Register** button at the bottom of the
page.

## Update the CodeStream Config and Restart

After you register the app, you'll be presented with a page similar to this.

![New REST App](../assets/images/issue/azuredevops/03 Get Secrets.png)

Take note of the **App ID** and **Client Secret** (do not confuse this with the
App Secret which is not needed; click the **show** button for this). Then update
your codestream config file, **~/.codestream/codestream-services-config.json**,
by adding the following section. The client secret is a very long string. Make
sure you do not add any characters (including carriage returns / newlines)
within the double quotes.

```
	"integrations": {
		"devops": {
			"cloud": {
				"appClientId": "-- App ID goes here --",
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
to Azure DevOps.
