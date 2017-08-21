# certbot-route53

This shell script helps create [Let's Encrypt](https://letsencrypt.org) certificates for
[AWS Route53](https://aws.amazon.com/route53). It uses [Certbot](https://certbot.eff.org) to automate certificate
requests, and the [AWS CLI](https://aws.amazon.com/cli/) to automate DNS challenge record creation.

## Manual installation & usage

1. Install Certbot and the AWS CLI. You can use [Homebrew](https://brew.sh/) (`brew install awscli certbot`)
   or [pip](https://pypi.python.org/pypi/pip) (`pip install boto3 certbot`).

2. [Configure the AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).
   Your account must have permission to list and update Route53 records.

3. Download the [certbot-route53.sh](https://git.io/vylLx) script.

```sh
mkdir my-certificates
cd my-certificates
curl -sL https://git.io/vylLx -o certbot-route53.sh
chmod a+x certbot-route53.sh
```

4. Run the script with your (comma-separated) domain(s) and email address:

```sh
sh certbot-route53.sh \
  --agree-tos \
  --manual-public-ip-logging-ok \
  --domains jed.is,www.jed.is \
  --email $(git config user.email)
```

5. Wait patiently (usually about two minutes) while, for each domain requested:

- Certbot asks Let's Encrypt for a DNS validation challenge string,
- AWS CLI asks Route53 to create a domain TXT record with the challenge value,
- Let's Encrypt validates the TXT record and returns a certificate, and finally
- AWS CLI asks Route53 to delete the TXT record.

6. Find your new certificate(s) in the `letsencrypt/live` directory.

![terminal](https://cloud.githubusercontent.com/assets/4433/23584470/9306b8ac-0130-11e7-9ffc-ef7d91971620.png)

## Using Docker

You can optionally use [Docker](https://www.docker.com/) to avoid installing all the necessary build tools & jump
straight into authenticating certificates. This assumes that (a) you have installed Docker, (b) you have done **step 2**
above (either by installing the AWS-CLI manually or using an AWS-CLI Docker container to configure your machine) and (c)
have your AWS configuration files at `~/.aws` as standard.

```sh
$ git clone https://github.com/car-throttle/certbot-route53
$ cd certbot-route53 && docker build -t certbot-route53:latest .
$ mkdir -p $PWD/letsencrypt
$ docker run -it --rm -v $HOME/.aws:/root/.aws:ro -v $PWD/letsencrypt:/root/letsencrypt \
  certbot-route53:latest certbot-route53.sh \
  --agree-tos \
  --manual-public-ip-logging-ok \
  --domains jed.is,www.jed.is \
  --email $(git config user.email)
```

You'll find your certificate(s) in `letsencrypt/live` directory too :wink:

And to renew:

```sh
$ docker run -it --rm -v $HOME/.aws:/root/.aws:ro -v $PWD/letsencrypt:/root/letsencrypt \
  certbot-route53:latest certbot-route53.sh renew
```
