# Slack Integration

In addition to authentication, the _**CodeStream - Slack**_ integration enables
you to use Slack as your messaging platform.  Full functionality of the platform
requires your CodeStream API service respond to requests made by Slack. That
usually means some kind of public facing proxy be put in place. It also means
the hostname you use for CodeStream may differ from the one you configure in the
Slack App.

All requests made by slack are signed and verified using [Slack's procedure for
doing so](https://api.slack.com/docs/verifying-requests-from-slack).

## Slack Access without a Publicly Accessible CodeStream API

For basic connectivity to slack, complete the following steps. You will need Administrator access to your Slack workspace to do this.

1. Create the Slack App for connecting CodeStream.
    * Go to https://api.slack.com/apps, make sure you're logged in to your
      workspace with administrative privileges, and press **Create New App**. We
      recommend naming it **CodeStream OnPrem**.
    * On the **OAuth & Permissions** page, in the **Scopes** section add the
      **Confirm user’s identity (identity.basic)** scope and press the "Save
      Changes" button.
    * Also on the **OAuth & Permissions** page, in the **Redirect URL's**
      section, add the URL
      `https://<your-codestream-host>/no-auth/provider-token/slack`
      and press the "Save URLs" button (substitute your codestream hostname
      here).
    * On the **Basic Information** page, install the App into your workspace 
    * Finally, you need to distribute it (this does NOT submit it to the Slack
      App Directory). To distribute the app, on the left rail under settings,
      select **Manage Distribution**. On the middle of that page press the
      `"Activate Distribution"` button (you may need to check off a few items on
      the checklist below to make that button available). Since you won't be
      submitting the App to the Slack App directory, these values don't really
      matter.

- Update your CodeStream services configuration file.
    * Add the following section to your config file:
      ```
      "integrations": {
          "slack": {
              "slack.com": {
                  "appClientId": "slack-app-client-id",
                  "appClientSecret": "slack-app-client-secret",
                  "interactiveComponents": false,
                  "signingSecret": null,
                  "appStrictClientId": "slack-app-client-id",
                  "appStrictClientSecret": "slack-app-client-secret",
                  "interactiveComponents": false,
                  "signingSecret": null
              }
          }
      }
      ```
    * Get the *slack-app-client-id* from the **Basic Information** page and add
      it to your CodeStream configuration file for both properties above.
    * Copy the *slack-app-client-secret* and add it to your CodeStream
      configuration for both properties above.

## Add Interactive Components access for your CodeStream Slack App

For the richest experience, you need to enable Slack's servers to make https
calls to your CodeStream API container. This means making particular routes on
your CodeStream API available to the public. [Slack requests are
signed](https://api.slack.com/docs/verifying-requests-from-slack) so attack
vectors are minimized.

Whomever governs your network infrastructure will likely have requirements on
how to do this. We've included one example of one method, using an
[Nginx](http://nginx.org) web server configured to enable proxy requests, so you
can see one way of accomplishing this.

### Configure an Nginx Proxy

Before you begin, you need to make sure the fully qualified hostname of your
public facing proxy is resolvable across public DNS servers and make sure it has
a valid SSL certificate. For this example, we'll use `my-proxy.my-domain.com` as
that hostname.

1. Install an Nginx proxy on a bastion host which listens on port 443 on the IP
   address associated with `my-proxy.my-domain.com`.

1. Add this virtual host configuration to your Nginx configuration. This only
   proxies the one route for slack interactive callbacks.
  ```
  server {
    listen 443 ssl;
    server_name my-proxy.my-domain.com;
    access_log /var/log/nginx/csproxy.access.log main;
    error_log /var/log/nginx/csproxy.error.log;

    ssl_certificate /path/to/full/cert/chain/my-certificate-chain.pem;
    ssl_certificate_key /path/to/cert/key/my-certificate-key.pem;

    location /no-auth/provider-action/slack) {
      #return 302 https://codestream.my-company.com/no-auth/provider-action/slack;
      resolver 10.101.0.2; // replace with ip of your host's resolver
      proxy_set_header Host codestream.my-company.com;
      proxy_pass https://codestream.my-company.com/no-auth/provider-action/slack;
    }

    location / {
      return 404;
    }
  }
  ```

1. Go to your [Slack App configuration](https://api.slack.com/apps), navigate to
   the **Basic Information** page and look for the **Signing Secret** in the
   **App Credentials** section. Copy the signing secret.

1. Add the signing secret to the Slack configuration section in your codestream
   config file.
  ```
      "integrations": {
          "slack": {
              "slack.com": {
                  "appClientId": "slack-app-client-id",
                  "appClientSecret": "slack-app-client-secret",
                  "interactiveComponents": true,
                  "signingSecret": "paste-signing-secret-here",
                  "appStrictClientId": "slack-app-client-id",
                  "appStrictClientSecret": "slack-app-client-secret",
                  "interactiveComponents": true,
                  "signingSecret": "paste-signing-secret-here"
              }
          }
      }
      ```
