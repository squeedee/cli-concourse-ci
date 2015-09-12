# CLI CI

This repo contains all public scripts and templates used to configure AWS and
Deploy, and configire Concourse CI for the 
[Cloud Foundry CLI](https://github.com/cloudfoundry/cli). It is used in concert 
with a private repo that contains all necessary secret information for your planned 
deployment as described below.

This work is copied from the [MEGA CI](https://github.com/cloudfoundry/mega-ci) repo
where all these elegant encapsulations were created.

#### Contents

1. [General Requirements](#general-requirements)
2. [Deployment Directory Details](#deployment-directory-details)
3. [Setting up Your AWS Environment and Deploying BOSH](#setting-up-your-aws-environment-and-deploying-bosh)
4. [Deploying Concourse](#deploying-concourse)

## General Requirements

* An AWS account for your Concourse deployment. It doesn't need to be empty as
  we can contain everything inside a VPC.

* The `aws` command line tool. You should run `aws configure` after
  installation to authenticate the CLI.

* The `bosh` command line tool.  This can be installed by running `gem install bosh_cli`

* The `bosh-init` command line tool. Instructions for installation can be found
  [here][bosh-init-docs].

* The `jq` command line tool. This can be installed by running `brew install jq`
  if you have Homebrew installed.

* The `spiff` command line tool. The latest release can be found [here]
  [spiff-releases].

## Deployment Directory Details

Unlike the Mega-CI version of these scripts, you need only:

```shell
export DEPLOYMENT_DIR=~/path/to/deployment/dir
```

Minimal folder structure requirments:

```
my_deployment_dir/
|- aws_environment
|- stubs/
   |- bosh/
   |  |- bosh_passwords.yml
```

The `aws_environment` file should look like this:

```bash
export AWS_DEFAULT_REGION=REPLACE_ME # e.g. us-east-1
export AWS_ACCESS_KEY_ID=REPLACE_ME
export AWS_SECRET_ACCESS_KEY=REPLACE_ME
```

The `stubs/bosh/bosh_passwords.yml` should look like this:

```yaml
bosh_credentials:
  agent_password: REPLACE_WITH_PASSWORD
  director_password: REPLACE_WITH_PASSWORD
  mbus_password: REPLACE_WITH_PASSWORD
  nats_password: REPLACE_WITH_PASSWORD
  redis_password: REPLACE_WITH_PASSWORD
  postgres_password: REPLACE_WITH_PASSWORD
  registry_password: REPLACE_WITH_PASSWORD
```

## Setting up Your AWS Environment and Deploying BOSH

Run:

```bash
./scripts/deploy_bosh
```

This will execute the AWS cloud formation template and then create a BOSH
instance. The script generates several artifacts in your deployment directory:

* `artifacts/deployments/bosh.yml`: the deployment manifest for your BOSH instance
* `artifacts/deployments/bosh-state.json`: an implementation detail of `bosh-init`;
  used to determine things like whether it is deploying a new BOSH or updating an
  existing one
* `artifacts/keypair/id_rsa_bosh`: the private key created in your AWS
  account that will be used for all deployments; you will need this if you ever
  account that will be used for all deployments; you will need this if you ever
  want to ssh into the BOSH instance or any of the concourse instances.

The script will also print the IP of the BOSH director. Target your director by running:

```bash
bosh target DIRECTOR_IP
```

The default username/password is admin/admin. You are **strongly advised** to change
these by running:

```bash
bosh create user USERNAME PASSWORD
```

When you're done, create a file called `bosh_environment` at the root of your
deployment directory that looks like this:

```bash
export BOSH_USER=REPLACE_ME
export BOSH_PASSWORD=REPLACE_ME
export BOSH_DIRECTOR=https://REPLACE_ME_WITH_BOSH_DIRECTOR_IP:25555
```

## Deploying Concourse

Run:

```bash
./scripts/deploy_concourse
```

The script will deploy Concourse. It generates one additional artifact in your
deployment directory:

* `artifacts/deployments/concourse.yml`: the deployment manifest of your Concourse

The script will also print the Concourse load balancer hostname at the end. This can be
used to create the `CNAME` for your DNS entry in Route53 so that you can have a nice
URL where you access your Concourse.

This script requires your deployment directory to have a few more things, in addition to the
minimal structure mentioned above:

```
my_deployment_dir/
|- aws_environment
|- certs/
|  |- concourse.pem
|  |- concourse.key
|  |- (concourse_chain.pem, optional)
|- cloud_formation/
|  |- (properties.json, optional)
|- stubs/
   |- bosh/
   |  |- bosh_passwords.yml
   |- concourse/
   |  |- atc_credentials.yml
   |  |- binary_urls.json
   |- datadog/
   |  |- datadog_stub.yml
   |- syslog/
   |  |- syslog_stub.yml

```

You need an SSL certificate for the domain where Concourse will be accessible. The
key and pem file must exist at `certs/concourse.key` and `certs/concourse.pem`. If
there is a certificate chain, it should exist at `certs/concourse_chain.pem`.
You can generate a self signed cert if needed:
                                                                             
* `openssl genrsa -out concourse.key 1024`
* `openssl req -new -key concourse.key -out concourse.csr` For the Common Name, you must enter your self signed domain.
* `openssl x509 -req -in concourse.csr -signkey concourse.key -out concourse.pem`
* Copy `concourse.pem` and `concourse.key` into the certs directory.

The optional `cloud_formation/properties.json` file should look like this:

```json
[
  {
    "ParameterKey": "ConcourseHostedZoneName",
    "ParameterValue": "REPLACE_WITH_HOSTED_ZONE_NAME"
  },
  {
    "ParameterKey": "ELBRecordSetName",
    "ParameterValue": "REPLACE_WITH_HOST_NAME"
  }
]

```
If both `ConcourseHostedZoneName` and `ELBRecordSetName` are provided, a Route 53 hosted zone will be created with the given
`ConcourseHostedZoneName` name, and a DNS entry pointing at the new ELB will be created with the given
`ELBRecordSetName` name.

The `stubs/concourse/atc_credentials.yml` file should look like this:
```yaml
atc_credentials:
  basic_auth_username: REPLACE_ME
  basic_auth_password: REPLACE_ME
  db_name: REPLACE_ME
  db_user: REPLACE_ME
  db_password: REPLACE_ME
```

Finally, the `stubs/concourse/binary_urls.json` should look something like this:

```json
{
  "stemcell": "https://d26ekeud912fhb.cloudfront.net/bosh-stemcell/aws/light-bosh-stemcell-3068-aws-xen-hvm-ubuntu-trusty-go_agent.tgz",
  "concourse_release": "https://bosh.io/d/github.com/concourse/concourse?v=0.62.0",
  "garden_release": "https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release?v=0.303.0"
}
```

You can find the latest stemcells [here][bosh-stemcells]. Concourse (and associated garden releases) can be found [here][concourse-releases].

#### Optional stubs

Concourse can optionally be configured to send metrics to datadog by adding your
datadog API key to datadog_stub with this format:

```yaml
---
datadog_properties:
  api_key: YOUR_DATADOG_API_KEY
```

Additionally, you can configure syslog on concourse to use an external endpoint
with the syslog_stub (i.e. papertrail):

```yaml
---
syslog_properties:
  address: logs3.papertrailapp.com:YOUR_PAPERTRAIL_PORT
```

[concourse-releases]: https://github.com/concourse/concourse/releases
[bosh-init-docs]: https://bosh.io/docs/install-bosh-init.html
[bosh-stemcells]: http://bosh.io/stemcells
[spiff-releases]: https://github.com/cloudfoundry-incubator/spiff/releases
