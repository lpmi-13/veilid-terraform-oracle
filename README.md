# Veild Terraform Oracle

Since the [Oracle Cloud](https://www.oracle.com/uk/cloud/free/) free tier is enough to run two (COUNT EM!) AMD Compute VMs, that means all you need to do is sign up for an oracle account and you can run two veilid nodes for free!

You will _technically_ also need to be able to store your terraform state somehwere, but [Terraform Cloud](app.terraform.io) is super easy for that, and also free if you're just using it for yourself.

> FAIR WARNING!!!! Dealing with Oracle Cloud is NOT for the feint of heart...the process of actually setting up an account and bushwhacking through their docs to configure a simple token you can use to authenticate with terraform is fraught with peril and may make you immediately regret your decision.

[This](https://developer.hashicorp.com/terraform/tutorials/oci-get-started/oci-build) is the best and simplest walk-through to follow, and even it requires multiple browser tabs open to work out what the hell is going on.

## Steps

1. Sign up for an Oracle Cloud Account

2. Download the OCI CLI

3. Authenticate with the OCI CLI and generate a session token
