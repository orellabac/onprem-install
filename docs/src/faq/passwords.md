---
title: How can I reset a user's password?
description: 
---

To reset a user's password and force them to change it upon their next login,
exectute the following command on the host OS:

```
~/.codestream/codestream --run-api-utility cs_api-set_user_password.js --email someUser@myCompany.com --password changeme --force-set
```
