---
title: Jira (Atlassian Cloud)
---

In order to integrate CodeStream with Jira on the Atlassian Cloud platform,
you'll need to create a Developer App to provide credentials to use their REST
API.

## Login to Atlassian Cloud and Go to Developer Apps

[Login to Atlassian Cloud](https://atlassian.com) and once logged in, go to
[Developer Apps](https://developer.atlassian.com/apps).

![dev apps](../assets/images/issue/jira/01 Developer Apps.png)


## Create a new Application for CodeStream Access

Press the **Create new app** button, select an application name, for example
**CodeStream On-Prem**, and agree to the developer terms of service.

![create app](../assets/images/issue/jira/02 Create App.png)

Once you press the **Create** button, you'll be placed on your newly created app's page.

![new app](../assets/images/issue/jira/03 App Created.png)

Take note of the Client ID and Secret.


## Add your REST API Permissions and Callback URL

Select **Permissions** on the navagation bar to bring up the api selections.

![feature](../assets/images/issue/jira/04 Permissions.png)

Select the **Jira platform REST API** option and then the configurue button.

![jira perms](../assets/images/issue/jira/05 Add Jira REST API.png)

Add the 3 scopes pointed to by the arrows above.


## Setup the Authorization

Now select **Authorization** on the left navagation bar and then the
**Cunfigure** action button.

![jira perms](../assets/images/issue/jira/06a Authorization.png)

Now add your callback URL. It should reference your company's CodeStream On-Prem
hostname with this path:

`https://codestream-onprem.mycompany.com/no-auth/provider-token/jira`

![callback](../assets/images/issue/jira/06 Add Callback.png)


## Take Note of the Client Id and Secret

Click on **Settings** on the left nav bar and take note of the Client ID
and Secret.

![jira perms](../assets/images/issue/jira/08 Settings.png)

## Update the CodeStream Config and Restart

Fnally, update your codestream config file,
**~/.codestream/codestream-services-config.json**, by adding the following
section using the Client ID and Secret from earlier.

```
	"integrations": {
		"jira": {
			"cloud": {
				"appClientId": "-- Client ID goes here --",
				"appClientSecret": "-- Secret goes here --"
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
to Jira.
