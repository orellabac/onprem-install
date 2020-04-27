# CodeStream On-Prem

[Click here for the guide to installing and configuring CodeStream
On-Prem.](https://docs.codestream.com/onprem)

## Releases

The installation supports **releases** (tagged versions). We currently have
three, but you can make as many as you want.

*   **Beta** - Beta runs containers made from docker images created from the
    _develop_ branch of the backend services. Note that these images reside in
    their own repos on the docker hub registry.
*   **Pre-Release** - Pre-Release containers are made from the _master_ branch
    of the backend services, but have not been made generally available yet.
*   **GA** - General Availability is the officially supported version of
    CodeStream On-Prem. It consists of docker images created from the _master_
    branch of the backend services.

This is implemented by:

*   Creating both a [version file
    here](https://github.com/TeamCodeStream/onprem-install/tree/master/versions)
    and a [configuration template
    here](https://github.com/TeamCodeStream/onprem-install/tree/master/config-templates).
    The suffix of these two files (which must match) is the _tagged version_.

*   Specify the release you want to use in the _~/.codestream/_ directory of the
    host OS. For example:
	```
	echo beta > ~/.codestream/release
	```

## Branch Development

Since customers accees the master branch of this repo, in order to test any work
you're doing on it, simply create a branch for your work and specify the branch
name in the _~/.codestream/_ directory of the host OS. For example:

```
echo my-feature-branch-name > ~/.codestream/installationBranch
```
