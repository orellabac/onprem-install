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
[Atom](https://atom.io/packages/codestream)).

Before signing up, each developer will need to point their IDE extension at your
CodeStream On-Prem server. Developers who were invited and received their
invitation code won't need to do this as the information about your CodeStream
On-Prem server is baked into the code. Those registering for an account who do
not have a code (which at a minimum includes the first person to register and
create a team) will need to update their CodeStream extension URL and StrictSSL
settings, otherwise they will inadvertantly create an account on the CodeStream
Cloud service.

Below are instructions for setting the server URL for each IDE that you can
distribute to the developers. Obviously, replace the sample URL with the actual
server URL for your On-Prem installation. It's important that developers do this
_after_ they've installed the CodeStream extension, but _before_ they sign up.

## JetBrains
-   Go to **Preferences > Settings > Tools > CodeStream** and add your CodeStream
    Server URL and protocol: `http(s)://<your.codestream.server>`.
-   If you are using a self-signed SSL certificate, also check the **Disable
    Strict SSL** box and then restart your IDE.

## Visual Studio Code
-   Click on the gear menu at the bottom of the activity bar and select
    **Settings**. In the Settings tab that opens search for **CodeStream** and
    then add your CodeStream Server URL and protocol:
    `http(s)://<your.codestream.server>`.
-   If you are using a self-signed SSL certificate, also check the **Disable
    Strict SSL** box and then restart your IDE.

## Visual Studio
-   Go to **Tools > Options** and select **CodeStream** in the left pane. Then enter
    your CodeStream Server URL and protocol in the right pane:
    `http(s)://<your.codestream.server>`.
-   If you are using a self-signed SSL certificate, also check the **Disable
    Strict SSL** box and then restart your IDE.

## Atom
-   Go to **Preferences > Settings > Packages** and look for the **CodeStream**
    entry in the Community Packages section. Click on the **Settings** button
    and then enter your CodeStream Server URL and protocol:
    `https://<your.codestream.server>`.
-   If you are using a self-signed SSL certificate, also check the **Disable
    Strict SSL** box and then restart your IDE.