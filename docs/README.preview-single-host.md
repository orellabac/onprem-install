
# CodeStream OnPrem - Single Host Preview

The single host preview of CodeStream OnPrem uses one docker container for each
of the CodeStream services (there is no scaling or redundancy). All containers must run on a single docker **host**. The host must run Linux. Docker containers
will run as a docker **host** network type.

This has been tested on Amazon Linux AMI (RedHat, CentOS, Fedora, ...).


## Check the prerequisites
You will need...
1. A linux server with docker installed and running. It should have the
   `docker-compose` and `curl` commands available as well. Make sure the system
   user account you intend to use for running CodeStream is able to run docker
   commands.  The fully qualified hostname of the linux server should be
   resolvable in DNS and you'll need it for the installation.

1. A valid SSL wildcard certificate along with it's corresponding key and
   certificate authority bundle (3 files in all). They should all be in pem
   format.

1. At this time, CodeStream OnPrem is invitation only. You will need an
   account on [Docker Hub](https://hub.docker.com) and you will need to be
   invited to the TeamCodeStream organization.

To simplify the initial configuration, there is a **bash** script that will take
you through the configuration process. You can also use it to control the
container services.

----
## Install the config script and create the configuration file

1. In a new terminal window, login to the docker host as the user which will run
   the docker commands and put the **CodeStream OnPrem** installation script in
   the installation directory (~/.codestream/).
    ```
    $ mkdir ~/.codestream
    $ cd ~/.codestream
    $ curl https://raw.githubusercontent.com/TeamCodeStream/onprem-install/master/install-scripts/single-host-preview-install.sh -o single-host-preview-install.sh
    $ chmod +x single-host-preview-install.sh
    ```

1. Run the script to create a base configuration. It's interactive. Once this
   step is complete, you will have a configuration file,
   *~/.codestream/codestream-services-config.json*, which you will be editing in
   subsequent steps.
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


## Complete any optional configuration settings

[Click here for configuring 3rd Party integrations](README.integrations.md) including Slack.



---------
## Starting and Stopping CodeStream Services

### Login to Docker Hub
The containers are accessible only to those who've been granted access so
you must first login to your docker hub account.
```
$ docker login
```

### Start the services
This first time you run this, it will download containers and setup a mongo
docker volume.
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
