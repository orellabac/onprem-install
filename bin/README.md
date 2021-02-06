# Executables and Entry Point

The sandbox's **bin/** directory stores scripts, utilities and other executable
commands associated with the sandbox. It should also provide the command(s)
representing the entry point of services provided. The **bin/** directory is
added to your search path when the sandbox is loaded.

## Naming and Execution Convention
Naming convention for commands is `<sb_prefix>-<useful_name>` where
`<sb_prefix>` is a lower case version of `$SB_PREFIX` defined in the sandbox
info file (`<sandbox_root>/sb.info`). Here's an example list of a **mongo**
sandbox's executables:
```
% ls $MDB_TOP/bin
mdb-add-user                 mdb-cmd                      mdb-mongo
mdb-archive-server           mdb-copy-prod-mongo-to-local mdb-service
mdb-backup                   mdb-dump-db                  mdb-vars
mdb-backup-util              mdb-help
%
```
Generally speaking, scripts should be executable and, if they use an interpreter
such as bash, python or node, should include the following first line which
will _locate_ it in the environment in lieu of assuming a fixed location.
```
#!/usr/bin/env <interpreter>
```

## Help and Usage

The `<sb_prefix>-help` command provides a useful listing of commands along
with a brief, one line description. For a command to appear in this listing
it must follow the naming convention above, and contain a single line
comment in one of the following forms:
```
    # desc# here is a one line description that works with bash and python

    // desc// here is a one line description that works with javascript
```

Doing so gives you this, for example:
```
% mdb-help
mdb-add-user                     Add users to mongo server
mdb-archive-server               dump or drop & restore all mongo dbs to a single compressed archive file
mdb-backup                       backup mongo databases and copy them to S3
mdb-cmd                          run a mongo command line utility
mdb-dump-db                      Dump mongo database with sandbox options
mdb-help                         brief command descriptions
mdb-mongo                        run the mongo shell (CLI)
mdb-service                      mongo service init script
mdb-vars                         Display sandbox environment variables
%
```

## DevTools API Integration

Some _special_ commands provide an integration hook into the **dtOps API** used
for automation throughout the build, deployment & other operational processes.
For example, `<sb_prefix>-service` is the init script used to start/stop
services in the sandbox. `<sb_prefix>-tc-buildstep` is the build system
integration hook, and so on. Templates for these commands are included when a
repo is _sandboxified_. At a minimum, they _must_ satisfy their respective usage
in both expectation and syntax.
