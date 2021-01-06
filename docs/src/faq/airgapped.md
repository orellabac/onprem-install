---
title: What if my host OS can't access The Internet?
description: 
---

CodeStream On-Prem will work on a host OS disconnected from the Internet, we
call this an **Air Gapped installation**, but since the docker containers still
have to be downloaded, you'll need a computer connected to the internet to
prepare software.

Run these commands on an internet-connected computer **running docker
services**, which is also capable of running a `bash` script, `git` and the unix
`tar` utility. Linux, OSX or Windows with WSL should all be capable. While you
won't actually run the CodeStream containers on this computer, you will be
downloading docker images to it. It should also have at least 12GB of available
disk space in order to package everything up.

1.	Download the CodeStream On-Prem package builder script.
	```
	curl -s https://raw.githubusercontent.com/TeamCodeStream/onprem-install/offline-install/install-scripts/util/build-pkg -o build-pkg
	chmod +x build-pkg
	```

1.  Run the script. This will create a rather large tarball (~1.75-2GB) and
    place it in `$HOME/codestream-package/`.
	```
	./build-pkg
	```
	
1.  Copy the tarball from that directory to your air gapped host, login to the
    host and untar it. This will create a `~/.codestream/` directory with all
    the software.
	```
	tar xzf <tar-file-name-here>
	```

1.	Proceed with the quickstart installation.
	```
	cd ~/.codestream
	./codestream --quickstart
	```

Be prepared to repeat this process in order to get upgrades. You may want to
leave the docker service with the images on your internet-connected machine so
as not to have to re-download every image each time you update CodeStream.
