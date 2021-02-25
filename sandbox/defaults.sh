
# This file contains all the default variable settings for the sandbox.
# These settings should work on every developer's machine upon installation.

# There are 3 sandbox related variables that are pre-defined prior to
# sourcing in this file. They are:
#
#  OPI_NAME     Name of the installed sandbox (installation specific)
#  OPI_TOP      Path up to and including the sandbox's primary git project
#         (eg. this file is OPI_TOP/sandbox/defaults.sh)
#  OPI_SANDBOX  Path to the root directory of the sandbox tree

# this shell library contains shell functions for manipulating sandboxes
. $DT_TOP/lib/sandbox_utils.sh || { echo "error loading library $DT_TOP/lib/sandbox_utils.sh" >&2 && return 1; }


# Installation options
# --------------------
# You can override a sandbox's configuration variables by placing
# 'VARIABLE=VALUE' assignments into $MY_SANDBOX/sb.options.  These
# settings will override any others specified in the sandbox config.
# Each row is stricly a KEY=VALUE assignment. Do not write shell
# code. Use a hash (#) for comments.
sandutil_load_options $OPI_SANDBOX || { echo "failed to load options" >&2 && return 1; }


# ------------- Yarn --------------
# Uncomment and setup if yarn is required. Available versions can be seen
# with the command:
#   ssh $DT_CLOUD_SERVER ls /home/web/SandboxRepos/software/yarn-$DT_OS_TYPE-*
# export OPI_YARN=true
# export OPI_YARN_VER=latest
# export PATH=$OPI_SANDBOX/yarn/bin:$PATH


# ------------- Node --------------
# Uncomment and setup if node is required. Available versions can be seen
# with the command:
#   ssh $DT_CLOUD_SERVER "ls /home/web/SandboxRepos/software/node-$DT_OS_TYPE-*"
export OPI_NODE_VER=12.14.1
export PATH=$OPI_SANDBOX/node/bin:$OPI_TOP/node_modules/.bin:$PATH


# Add $MY_SANDBOX/bin to the search path
export PATH=$OPI_TOP/bin:$PATH

# if you want to short circuit the sandbox hooks (see hooks/git_hooks.sh) either uncomment
# this in defaults.sh or add 'OPI_DISABLE_GIT_HOOKS=1' to OPI_SANDBOX/sb.options
# export OPI_DISABLE_GIT_HOOKS=1

# Standard variables for all sandboxes - USE THESE TO INTEGRATE WITH OPS!!!
export OPI_LOGS=$OPI_SANDBOX/log    # Log directory
export OPI_TMP=$OPI_SANDBOX/tmp     # temp directory
export OPI_CONFS=$OPI_SANDBOX/conf  # config files directory
export OPI_DATA=$OPI_SANDBOX/data   # data directory
export OPI_PIDS=$OPI_SANDBOX/pid    # pid files directory

# The asset/artifact build environment; usually 'local', 'dev' or 'prod'
# https://github.com/TeamCodeStream/dev_tools/blob/master/README/README.deployments.md)
[ -z "$OPI_ASSET_ENV" ] && export OPI_ASSET_ENV=local

# The sandbox run-time environment;  eg. 'local', 'qa', 'prod', 'loadtest1', ...
# https://github.com/TeamCodeStream/dev_tools/blob/master/README/README.deployments.md)
[ -z "$OPI_ENV" ] && export OPI_ENV=local
