# CodeStream On-Prem

**CodeStream On-Prem** refers to a self-installed instance of the CodeStream
server-side services which you can operate entirely on your own premises (or
cloud provider). You only need a linux host OS running Docker services.

If you intend to configure Slack or MS Teams messaging, or if you plan to
configure any integrations with, or authentication by, other cloud service
providers (such as Github, Atlassian, Asana, Trello, Azure DevOps, Bitbucket,
Gitlab, etc...) you will need to provide a public-facing web proxy for OAuth
callbacks from those providers.

If you intend to use built-in CodeStream messaging, you will need a mail relay
server or mail submission account that accepts email sent by the CodeStream
host. If you want email replies to email notifications to flow back into the
conversations (support for the *CodeStream inbound email gateway*) you will need
to configure mail routing (MX) for a mail domain dedicated to this task (for
example, @codestream.my-company.com) to provide delivery using standard SMTP
protocols.

CodeStream On-Prem is only available in a preview configuration at this time.

The *CodeStream inbound email gateway* is not available at this time.

[Click Here](docs/README.preview-single-host.md) for setting up a preview environment
on a single linux host OS running Docker services.
