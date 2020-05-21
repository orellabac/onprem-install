---
title: Single Linux Host
description: Run containers on a single linux host OS
---

The **Single Linux Host** configuration of CodeStream On-Prem uses one docker
container for each of the CodeStream services (there is no scaling or
redundancy) all running on a single host. Due to limitations of docker's
implementation on some OS's, you must use Linux for the host OS. This limitation
is imposed due to filesystem compatibility and host based networking.

The [Quick Start](/#quick-start) instructions on the On-Prem Administration home
page provides instructions for setting up the simplest **Single Linux Host**
configuration.

CodeStream clients (IDE extensions) make requests to the API
service on port **80** using **HTTP** and the Broadcaster on port **12080**
using **HTTP websockets**.


## Extend CodeStream's Capabilities

Here are links to a few of the ways to extend your installation's capabilities.

*  [Add SSL Certificates](../ssl/ssl) to secure all communications throughout
   the system. You can use certificates issued by accredited Certificate
   Authorities or your own self-signed certificates.

*  [Configure an outbound email service](../email/outbound) to enable
   notifications & invitations via email.

*  [Add a messaging integration](../messaging/network) to share your codemarks
   with your team's existing messaging service and take the conversation beyond
   the confines of your IDE.

*  [Add Issue Integrations](../issues/overview) to connect your codemarks with
   your team's existing issue tracking and management tools.


## Basic Commands

Most administrative functions are executed through a control script called
`~/.codestream/codestream` on the host OS.  Here are the most common ones you
should expect to use.

### Start the services
Start up all the services (containers). If the docker image versions haven't
already been downloaded, this will download them first.
```
~/.codestream/codestream --start
```

### Stop all the services
This stops the containers but does not destroy them.
```
~/.codestream/codestream --stop
```

### Stop all the services except for mongo
In the event you need to do some database maintenance, this will stop all the
codestream services except for MongoDB.
```
~/.codestream/codestream --stop-execpt-mongo
```

### Check the status of your containers and mongo data volume
```
~/.codestream/codestream --status
```

### Backup your mongo database to the host operating system
This will dump the contents of the mongo database to a single archive file in
`~/.codestream/backups/`.
```
~/.codestream/codestream --backup
```

### Update your system to the latest version
This will backup your mongo database before doing the update.
```
~/.codestream/codestream --update-myself
~/.codestream/codestream --update-containers
```

### Restore your mongo database from the host operating system
This will restore the contents of the mongo database from a prior backup in
`~/.codestream/backups/`. Specify **latest** to restore the most recent backup.
```
~/.codestream/codestream --restore {latest | <file>}
```

### Backup your mongo database and the entire configuration directory
This will create a tarball (compressed tar archive file) in the home directory
of the unix user on your host OS. It is a copy of the entire system including
all previous database backups and configuration files.
```
~/.codestream/codestream --full-backup
```

### Reset your installation
This will delete your containers so new ones will be created the next time you
start the services. In the case of mongo, this _should_ leave the mongo docker
data volume intact, but make sure you backup the database _BEFORE_ doing a
reset.
```
~/.codestream/codestream --backup
~/.codestream/codestream --reset
```
This will reset all the containers _except_ mongodb.
```
~/.codestream/codestream --reset-except-mongo
```

## Routine Maintenance

It is important for you to perform these tasks regularly.

### Keep your system up to date

We have to keep up with the fast pace of development today's software tools
demand, so you'll need to keep your CodeStream system current as well. It's fast
and easy to do. [Just follow this update
procedure](#update-your-system-to-the-latest-version).

### Backup your system

The importance of backups cannot be overstated. [Follow this backup
procedure](#backup-your-mongo-database-and-the-entire-configuration-directory)
to create a full backup of your installation. As it only backs up to a file on
the host OS, it is important you copy that file to another device for safe
keeping in the event of a catastrophic failure.
