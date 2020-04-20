---
title: Single Linux Host
description: Run containers on a single linux host OS
---

The **Single Linux Host** configuration of CodeStream On-Prem uses one docker
container for each of the CodeStream services (there is no scaling or
redundancy) all running on a single host. Due to limitations of docker's
implementation on some OS's, you must use Linux for the host OS. This limitation
is imposed due to filesystem compatibility and host based networking.

## Prerequisites

Before you begin...

*  Setup a linux server or VM with
   [docker](https://runnable.com/docker/install-docker-on-linux). You'll need to
   be able to login to your host OS using a terminal program and you should have
   some basic familiarity working with the command line shell.

*  The host must have the `curl` command.

*  Make sure the system user account you intend to use for running CodeStream
   is able to run docker commands _without_ **sudo**.

*  Ensure that IDE clients and the host OS resolve the same hostname to the same
   IP address.
   
*  Obtain a valid SSL wildcard certificate (self-signed is ok) along with it's
   corresponding key and optional certificate authority bundle (2 or 3 files in
   all). They should all be in PEM format. At this time, CodeStream On-Prem
   requires secure communication (HTTPS).

*  Clients will connect to two of the services (containers) running on the linux
   host OS; the **API** and the **Broadcaster**. When using an SSL certificate,
   these services default to ports 443 and 12443 respectively so those ports
   must be open to the clients.

*  At this time **CodeStream On-Prem** is invitation only. You will need an
   account on [Docker Hub](https://hub.docker.com) and you will need to be added
   to the _TeamCodeStream_ organization. Send an email to
   [sales@codestream.com](mailto:sales@codestream.com) with your Docker Hub ID
   to request access.



## Install the control script and create the configuration file

To simplify everything, we've created a **bash** shell script that you'll use to
configure and manage your installation.

1. Login to your linux host OS. As the docker images are restricted you'll need
   to login to your docker hub account.
   ```
   docker login
   ```

1. Create the configuration directory and install the **bash** control script.
   ```
   mkdir ~/.codestream
   cd ~/.codestream
   curl -O https://raw.githubusercontent.com/TeamCodeStream/onprem-install/master/install-scripts/single-host-preview-install.sh
   chmod +x single-host-preview-install.sh
   ```

1. Run the script to create a base configuration. It's interactive. Once this
   step is complete, you will have a configuration file,
   `~/.codestream/codestream-services-config.json`, which you will be editing in
   subsequent steps.
    ```
    single-host-preview-install.sh -a install
    ```

1. [Set up an outbound email gateway](../email/outbound). CodeStream
   relies on email for invitations and registration. CodeStream users can also
   enable email for notifications.

1. Start the services.
   ```
   ./single-host-preview-install.sh -a start
   ```

1. **IMPORTANT:** Before your users attempt to register and sign in to your
   CodeStream On-Prem installation they'll need to change their CodeStream
   extension settings to point their IDEs to it. If they don't, they'll end up
   creating an account in the CodeStream Cloud service. Provide them with your
   CodeStream On-Prem hostname as well as any additional options and have them
   [follow these instructions](../ide/overview) for configuring their
   respective IDEs.

**It is recommended that you get CodeStream On-Prem working prior to setting up
any integrations.**  Once you're up and running and are able to create
codemarks, checkout out the [messaging integrations](../messaging/network) and
[issue tracking integrations](../issues/overview) documentation to set
them up.


## Basic Administrative Commands

### Start the services
Start up all the services (containers). If the docker image versions haven't
already been downloaded, this will download them first.
```
~/.codestream/single-host-preview-install.sh -a start
```

### Stop all the services
This stops the containers but does not destroy them.
```
~/.codestream/single-host-preview-install.sh -a stop
```

### Stop all the services except for mongo
In the event you need to do some database maintenance, this will stop all the
codestream services except for MongoDB.
```
~/.codestream/single-host-preview-install.sh -M -a stop
```

### Check the status of your containers and mongo data volume
```
~/.codestream/single-host-preview-install.sh -a status
```

### Backup your mongo database to the host operating system
This will dump the contents of the mongo database to a single archive file in
`~/.codestream/backups/`.
```
~/.codestream/single-host-preview-install.sh --backup
```

### Update your containers to the latest version
This will backup your mongo database before doing the update.
```
~/.codestream/single-host-preview-install.sh --update-myself
~/.codestream/single-host-preview-install.sh --update-containers
```

### Reset your installation
This will delete your containers so new ones will be created the next time you
start the services. In the case of mongo, this _should_ leave the mongo docker
data volume intact, but make sure you backup the database _BEFORE_ doing a
reset.
```
~/.codestream/single-host-preview-install.sh --backup
~/.codestream/single-host-preview-install.sh -a reset
```
This will reset all the containers _except_ mongodb.
```
~/.codestream/single-host-preview-install.sh -M -a reset
```
