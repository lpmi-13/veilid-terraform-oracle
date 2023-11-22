# Veild Terraform Oracle

Since the [Oracle Cloud](https://www.oracle.com/uk/cloud/free/) free tier _should_ be enough to run two (COUNT EM!) AMD Compute VMs, that means all you need to do is sign up for an oracle account and _in theory_ you can run two veilid nodes for free! CAVEAT: I'm still testing if this is true, so caveat emptor.

> FAIR WARNING!!!! Dealing with Oracle Cloud is NOT for the feint of heart...the process of actually setting up an account and bushwhacking through their docs to configure a simple token you can use to authenticate with terraform is fraught with peril and may make you immediately regret your decision.

[This](https://developer.hashicorp.com/terraform/tutorials/oci-get-started/oci-build) is the best and simplest walk-through to follow, and even it requires multiple browser tabs open to work out what the hell is going on.

## Steps

1. Sign up for an [Oracle Cloud Account](https://www.oracle.com/cloud/sign-in.html)

2. Download the [OCI CLI](https://github.com/oracle/oci-cli)

It will take a bit of fiddling after running the `oci setup config` to get all your configuration right, so make sure you're sitting down.

3. Authenticate with the OCI CLI and generate a session token

```
oci session authenticate --no-browswer
```

And just choose the region you want to use.

> if you get logged out for any reason (this process shouldn't take more than 1-2 minutes) renew your credentials by running `oci session authenticate --no-browser` again.

4. Run `terraform init && terraform apply`.

5. Once the instance is booted up, it should start veilid automatically, but if you'd like to poke around, ssh in using the ssh key pair that you added in the terraform configuration.

```
ssh -i PATH_TO_YOUR_PRIVATE_KEY ubuntu@SERVER_IP_ADDRESS
```

> Note: if you try to SSH in too soon, you may see a message saying "System is booting up. Unprivileged users are not permitted to log in yet. Please come back later. For technical details, see pam_nologin(8)." Just try again in a minute or so.
