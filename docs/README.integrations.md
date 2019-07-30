# 3rd Party Integrations

## OAuth Callback Web Proxy Configuration
CodeStream supports integrations with 3rd party services, both in the cloud and
self-hosted. For the OAuth authentication process to work, these 3rd party
services must be able to make an https callback directly to the CodeStream API.

If your On-Prem service is sitting behind a firewall (highly recommended), you
will need to provide a public facing web proxy for this express purpose.

Following is an example configuration for an Nginx proxy.

Ensure your server's virtual hostname (eg.
**codestream-auth-proxy.my-company.com**) is publicly resolvable and reachable.


Here is a sample config to use as a guide:
  ```
  # Nginx proxy config to forward CodeStream auth requests coming from
  # 3rd party services to the CodeStream API
  server {
      listen 443 ssl;
      server_name my-codestream-proxy.my-company.com;
      access_log /var/log/nginx/codestream-proxy.access.log main;
      error_log /var/log/nginx/codestream-proxy.error.log;
      ssl_certificate /etc/pki/my-cert.fullchain;
      ssl_certificate_key /etc/pki/my-cert.key;

      if ($args !~ "state=(.+)(%21|!)") {
          return 302 "$uri";
      }

      set $p_host codestream-api-server.my-company.com;

      location /no-auth {
          # set this to your host's DNS resolver IP address 
          # (usually found in /etc/resolve.conf)
          resolver 10.101.0.2;
          proxy_pass https://$p_host$request_uri;
          proxy_set_header Host $p_host;
          return 302 https://$p_host$request_uri;
      }

      location / {
  	       return 404;
      }
  }
  ```

## Service Integrations

* [Instructions for setting up Slack](README.slack.md) which can be used for
  both authentication and messaging. You'll need to provide a Slack App for the
  integration (simple to create) and grant it access to your workspace. Once
  logged in via **Slack**, conversations will flow through channels you select.
