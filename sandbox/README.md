# The sandbox/ Directory

A _sandboxified_ project includes a `<repo-root>/sandbox/` directory. It will
contain the templates, hooks and most other data that act as _integration or
touch points_ with the dev_tools framework. Most of the work you do to create a
sandboxified project will happen here.

## Hooks

Hooks are executed within different stages of a sandbox's life or during
functions abstracted by the dev_tools framework (such as creating a docker image
or playground file).
