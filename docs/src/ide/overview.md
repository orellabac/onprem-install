---
title: IDE Configuration
description: Instructions for configuring client IDEs
---

The developers in your organization will need to install the CodeStream
extension in their IDE by downloading it from the appropriate marketplace (i.e.,
[VS
Code](https://marketplace.visualstudio.com/items?itemName=CodeStream.codestream),
[Visual
Studio](https://marketplace.visualstudio.com/items?itemName=CodeStream.codestream-vs),
[JetBrains](https://plugins.jetbrains.com/plugin/12206-codestream) or
[Atom](https://atom.io/packages/codestream)). Before proceeding with signup
though, each developer will need to update the settings in their IDE to point
CodeStream at your On-Prem installation, otherwise they'll end up creating an
account on CodeStream's cloud service.

Below are instructions for setting the server URL for each IDE that you can
distribute to the developers. Obviously, replace the sample URL with the actual
server URL for your On-Prem installation. Again, it's important that developers
do this after they've installed the CodeStream extension, but before they sign
up.

## JetBrains
- Go to Preferences/Settings > Tools > CodeStream and paste the following in for
  the Server URL: https://onpremurl.com
- If you are using a self-signed SSL certificate, also check the "Disable Strict
  SSL" box and then restart your IDE.

## Visual Studio Code
- Click on the gear menu at the bottom of the activity bar and select “Settings”
  . In the Settings tab that opens search for “CodeStream” and then paste the
  following in for the Server URL: https://onpremurl.com
- If you are using a self-signed SSL certificate, also check the "Disable Strict
  SSL" box and then restart your IDE.

## Visual Studio
- Go to Tools > Options and select CodeStream in the left pane. Then paste the
  following in for the Server URL in the right pane: https://onpremurl.com
- If you are using a self-signed SSL certificate, also check the "Disable Strict
  SSL" box and then restart your IDE.

## Atom
- Go to Preferences/Settings > Packages and look for the CodeStream entry in the
  Community Packages section. Click on the Settings button and then paste the
  following in for the Server URL: https://onpremurl.com
- If you are using a self-signed SSL certificate, also check the "Disable Strict
  SSL" box and then restart your IDE.