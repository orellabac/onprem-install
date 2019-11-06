
# CodeStream On-Prem - Single Host Preview

The single host preview of CodeStream On-Prem uses one docker container for each
of the CodeStream services (there is no scaling or redundancy). All containers
must run on a single linux host OS running docker. Docker containers will be
launched using the **network=host** parameter.

This has been tested on Amazon Linux AMI (RedHat, CentOS, Fedora, ...).


## Check the prerequisites
You will need...
1. A linux host OS (server or virtual machine) with [docker installed and
   running](https://runnable.com/docker/install-docker-on-linux).
    * It should have the `curl` command available
    * Make sure the system user account you intend to use for running CodeStream
      is able to run docker commands without **sudo**.
    * The fully qualified hostname should be resolvable for both the server
      itself and any clients or services that will connect to it, for example
      `codestream.my-company.com`.
   
1. Open ports 443 (for api calls) and 12443 (for broadcast services) to the
   client IDEs & the server itself (loopback).

1. Get a valid SSL wildcard certificate along with it's corresponding key and
   certificate authority bundle (3 files in all). They should all be in pem
   format. CodeStream requires secure communication (https).

1. At this time **CodeStream On-Prem** is invitation only. You will need an
   account on [Docker Hub](https://hub.docker.com) and you will need to be
   invited to the TeamCodeStream organization. Send an email to
   sales@codestream.com with your docker hub ID to request access.

To simplify the initial configuration, there is a **bash** script that will take
you through the installation. You'll also use it to control the containers and
perform maintenance functions.

----
## Install the config script and create the configuration file

1. The containers are accessible only to those who've been granted access on
   docker hub so you must first login to your docker hub account.
    ```
    $ docker login
    ```

1. In a new terminal window, login to the docker host as the user which will run
   the docker commands and put the **CodeStream On-Prem** installation script in
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

1. Perform the [outbound email gateway setup steps](README.email.md) if you
   intend to create On-Prem accounts or you want email notifications. This is
   optional if you intend to use Slack or MS Teams for authentication.

1. Follow the [configure integrations](README.integrations.md) if you intend to
   use Slack for authentication or as a messaging platform.

1. Inform your developers they'll need to change the default settings in their
   respective client IDE's to point them to your On-Prem version. The default
   behavior will have them pointing to CodeStream Cloud. Instructions for
   the supported IDE types [can be found here](README.clientsetup.md).


---------
## Starting and Stopping CodeStream Services

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

### See your containers and mongo data volume
```
$ ~/.codestream/single-host-preview-install.sh -a status
```

### Backup your data
```
$ ~/.codestream/single-host-preview-install.sh --backup
```

### Update your containers
```
$ ~/.codestream/single-host-preview-install.sh --update-myself
$ ~/.codestream/single-host-preview-install.sh --update-containers
```

### Stop the services and remove all the containers
Tthis _should_ leave the mongo data volume intact, but make sure you backup the
database _BEFORE_ doing a reset. Specify `-M` to exclude the mongo container
from the reset.
```
$ ~/.codestream/single-host-preview-install.sh [-M] -a reset
```
