
# CodeStream OnPrem - Single Host Preview

The single host preview of CodeStream OnPrem uses docker containers for all of
the CodeStream services. They run in a docker **host** network all on a single
host; each service will be accessible independently.

This has been tested on Amazon Linux AMI (RedHat, CentOS, Fedora, ...).


## Prerequisites

1. A linux server with docker installed and running. It should have the
`docker-compose` and `curl` commands available as well. Make sure the
system user account you intend to use for running CodeStream is able to run
docker commands.  The fully qualified hostname of the linux server should be
resolvable in DNS and you'll need it for the installation.

1. A valid SSL certificate along with it's corresponding Key file and
Certificate Authority bundle file (3 files). They should all be in pem
format.

1. To simplify the initial configuration, there is a **bash** script that will
take you through the configuration process. You can also use it to control
the container services.


## Setup the configuration file

### Required configuration settings
1. In a new terminal window, login to the docker host as the user which will run
the docker commands and get the CodeStream OnPrem installation script
    ```
    $ mkdir ~/.codestream
    $ cd ~/.codestream
    $ curl https://raw.githubusercontent.com/TeamCodeStream/onprem-install/master/install-scripts/single-host-preview-install.sh -o single-host-preview-install.sh
    $ chmod +x single-host-preview-install.sh
    ```

1. Run the script to create a base configuration. Once this step is complete, you
will have a configuration file, *~/.codestream/codestream-services-config.json*,
which you will be editing in subsequent steps.
    ```
    $ ./single-host-preview-install.sh -a install
    ```

1. Update the *emailDeliveryService.NodeMailer* section of the config file to
work with the SMTP mailer of your choice.  If you want to send email out via
a **GMail** or **G-Suite** account, set the following properties:
    ```
    "NodeMailer": {
        "service": "gmail",
        "host": "smtp.gmail.com",
        "port": "587",
        "username": "",  // Your GMail or G-Suite account email address (required)
        "password": "",  // Your GMail or G-Suite account password (required, plain text)
        "emailTo": ""    // if you want all mail diverted to a single address, enter it here (optional)
    }
    ```
    You must also configure your **GMail** or **G-Suite** account to allow
    less secure apps to access it. See this page for instructions on how
    to do that: https://support.google.com/accounts/answer/6010255 .

    For further information on other configurations see the **NodeMailer**
    documentation at https://www.npmjs.com/package/nodemailer .


### Optional configuration settings

#### Complete these steps if you want to use **Slack** for CodeStream's messaging and authentication.

Connecting Slack to CodeStream requires Slack servers to be able to send
https requests to the CodeStream API service. Since the CodeStream API will
likely run internally, you will need to setup an https proxy for these
requests. We provide an example of this using **nginx**.

- Setup your nginx proxy server where it is accessible to the public. Make
  sure your server's virtual hostname (eg.
  **codestream-auth-proxy.my-company.com**) is publicly resolvable to its public
  IP address.  Here is a sample config to use as a guide:
  ```
  # Nginx proxy config to forward CodeStream auth requests to the CodeStream API
  server {
      listen 443 ssl;
      server_name my-codestream-proxy.my-company.com;
      access_log /var/log/nginx/my-codestream-proxy.access.log main;
      error_log /var/log/nginx/my-codestream-proxy.error.log;
      ssl_certificate /etc/pki/my-cert.fullchain;
      ssl_certificate_key /etc/pki/my-cert.key;

      if ($args !~ "state=(.+)(%21|!)") {
          return 302 "$uri";
      }

      set $p_host codestream-api-server.my-company.com;

      location /no-auth {
          # set this to your host's DNS resolver IP address (usually found in /etc/resolve.conf)
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

- Create the Slack App for connecting CodeStream (you will not be publishing it).
    - Go to https://api.slack.com/apps, make sure you're logged in to your workspace
      with administrative privileges, and press **Create New App**. We recommend
      naming it **CodeStream OnPrem**.
    - On the **OAuth & Permissions** page, in the **Scopes** section add the
      **Confirm user’s identity (identity.basic)** scope and press the "Save
      Changes" button.
    - Also on the **OAuth & Permissions** page, in the **Redirect URL's** section,
      add the URL **https://my-codestream-proxy.my-company.com/no-auth/provider-token/slack**
      and press the "Save URLs" button.
    - On the **Basic Information** page, install the App into your workspace.

- Update your CodeStream configuration file.
    - Copy the *Client ID* from the **Basic Information** page and add it to your CodeStream
      configuration file for the `integrations.slack."slack.com".appClientId`
      property.
    - Copy the *Client Secret* and add it to your CodeStream configuration
      for the `integrations.slack."slack.com".appClientSecret` property.
    - Set the `apiServer.authOrigin` property to **"https://my-codestream-proxy.my-company.com/no-auth"**


## Starting and Stopping CodeStream Services

### Start the services
```
$ ~/.codestream/single-host-preview-install.sh -a start
```

### Stop the services
```
$ ~/.codestream/single-host-preview-install.sh -a stop
```

### Stop the services and remove all the containers
(this will leave the mongo data volume intact)
```
$ ~/.codestream/single-host-preview-install.sh -a reset
```

### See your containers and mongo data volume
```
$ ~/.codestream/single-host-preview-install.sh -a status
```
