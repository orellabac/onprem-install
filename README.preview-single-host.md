
# CodeStream OnPrem - Single Host Preview

The single host preview of CodeStream OnPrem installs docker containers for all
of the CodeStream services using a docker host network; each service will be
accessible independently, all running on single host. This has been tested on
Amazon Linux EC2 (RedHat, CentOS, Fedora, ...).

## Prerequisites
1. A linux server with the docker and docker-compose services installed and
running. Make sure the system user account you intend to use for running
CodeStream is able to run docker commands.

1. A valid SSL certificate along with it's corresponding Key file and
Certificate Authority bundle file.

## Setup the configuration

1. Clone the https://github.com/teamcodestream/codestream-onprem repository in
your home directory.
    ```
    $ cd $HOME
    $ git clone https://github.com/teamcodestream/codestream-onprem
    ```

1. Copy the template codestream config file from the onprem repo to the
predefined configuration directory (~/.codestream).
    ```
    $ mkdir ~/.codestream
    $ cp ~/codestream-onprem/config-templates/single-host-preview.json ~/.codestream/codestream-services-config.json
    ```

1. Copy your 3 SSL certificate files (cert, key & CA bundle) to the
~/.codestream/ directory.

1. Copy the docker compose YAML file from the onprem repo
    ```
    $ cp ~/codestream-onprem/docker-compose/single-host-preview.yaml ~/.codestream
    ```

## Starting and Stopping CodeStream

### Start the service for the first time
```
$ cd ~/.codestream
$ docker-compose -f single-host-preview.yaml up -d
```

### Stop the service
```
$ cd ~/.codestream
$ docker-compose -f single-host-preview.yaml stop
```

### Restart the service
```
$ cd ~/.codestream
$ docker-compose -f single-host-preview.yaml start
```

### Stop the service and remove all containers
```
$ cd ~/.codestream
$ docker-compose -f single-host-preview.yaml down
```

## Configuration Options

### SMTP (emailDeliveryService.NodeMailer)
CodeStream OnPrem uses the NodeMailer module for sending mail through SMTP
servers.

If you want to use an individual's GMail account for this purpose:
1. Setup the GMail account to allow less secure apps to send mail. See https://support.google.com/accounts/answer/6010255 .

1. Set the codestream config emailDeliveryService.NodeMailer properties as follows:
    ```
    {
        "service": "gmail",
        "host": "smtp.gmail.com",
        "port": "587",
        "username": "my-gmail-user@my-gmail-domain.com",
        "password": "your-gmail-password-in-plain-text",
        "emailTo": "on"  ???? VERIFY
    }
    ```
