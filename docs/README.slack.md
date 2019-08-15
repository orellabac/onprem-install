# Slack Integration

To connect CodeStream to Slack, complete the following steps.

1. Create the Slack App for connecting CodeStream.
    * Go to https://api.slack.com/apps, make sure you're logged in to your
      workspace with administrative privileges, and press **Create New App**. We
      recommend naming it **CodeStream OnPrem**.
    * On the **OAuth & Permissions** page, in the **Scopes** section add the
      **Confirm user’s identity (identity.basic)** scope and press the "Save
      Changes" button.
    * Also on the **OAuth & Permissions** page, in the **Redirect URL's**
      section, add the URL
      **https://my-codestream-proxy.my-company.com/no-auth/provider-token/slack**
      and press the "Save URLs" button (substitute your public facing hostname
      here).
    * On the **Basic Information** page, install the App into your workspace.
    * The app is now available to the workspace in which you created it. If you
      want to be able to select from any of your workspaces for authentication,
      you need to distribute your app (this does NOT submit it to the slack
      marketplace). To distribute the app, on the left rail under settings,
      select **Manage Distribution**. On the middle of that page press the
      `"Activate Distribution"` button (you may need to check off a few items on
      the checklist below to make that button available).

- Update your CodeStream services configuration file.
    - Add the following section to your config file:
      ```
      "integrations": {
          "slack": {
              "slack.com": {
                  "appClientId": "slack-app-client-id",
                  "appClientSecret": "slack-app-client-secret",
                  "appStrictClientId": "slack-app-client-id",
                  "appStrictClientSecret": "slack-app-client-secret",
              }
          }
      }
      ```
    - Get the *slack-app-client-id* from the **Basic Information** page and add
      it to your CodeStream configuration file for both properties above.
    - Copy the *slack-app-client-secret* and add it to your CodeStream
      configuration for both properties above.
    - Set the `apiServer.authOrigin` property to
      **"https://my-codestream-proxy.my-company.com/no-auth"**
