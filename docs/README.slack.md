# Slack Integration

To connect CodeStream to Slack, complete the following steps.

1. Create the Slack App for connecting CodeStream.
    * Go to https://api.slack.com/apps, make sure you're logged in to your
      workspace with administrative privileges, and press **Create New App**. We
      recommend naming it **CodeStream OnPrem**.
    * On the **OAuth & Permissions** page, in the **Scopes** section add the
      **Confirm user’s identity (identity.basic)** scope and press the "Save
      Changes" button.
    * Also on the **OAuth & Permissions** page, in the **Redirect URL's** section,
      add the URL **https://my-codestream-proxy.my-company.com/no-auth/provider-token/slack**
      and press the "Save URLs" button.
    * On the **Basic Information** page, install the App into your workspace.
    * The app is now available to the workspace you created it in. If you want
      to be able to select from any of your workspaces for authentication, you
      need to distribute your app (this does NOT submit it to the slack
      marketplace). On the left rail, under settings, select **Manage
      Distribution**. On the middle of that page press the "Activate
      Distribution" button (you may need to check off a few items on the
      checklist below to make that button available).

- Update your CodeStream services configuration file.
    - Copy the *Client ID* from the **Basic Information** page and add it to your CodeStream
      configuration file for the `integrations.slack."slack.com".appClientId`
      property.
    - Copy the *Client Secret* and add it to your CodeStream configuration
      for the `integrations.slack."slack.com".appClientSecret` property.
    - Set the `apiServer.authOrigin` property to **"https://my-codestream-proxy.my-company.com/no-auth"**
