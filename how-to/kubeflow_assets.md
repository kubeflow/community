# Kubeflow Assets

This doc is intended to provide an overview of the different assets 
which are used by the Kubeflow community and identify the respective owners.

## GitHub Org: kubeflow

https://github.com/kubeflow

The Kubeflow GitHub org is administered declaratively.

Admins can be found in [org.yaml](https://github.com/kubeflow/internal-acls/blob/e4303ff3c7299bde05b4a9c7519e8592c5137755/github-orgs/kubeflow/org.yaml#L7)

More info about how the GitHub org is administered in [GitHub Admin](https://github.com/kubeflow/community/blob/master/how-to/github_admin.md)


### GitHub Robots

https://github.com/kubeflow-bot

* Password is stored in GCP Secret Manager project `kubeflow-admin`
* You will also need a recovery token which are also stored in secret manager

  * These are onetime use so remove it when you use it
  * When you login you need to select use recovery token.

## kubeflow.org GSuite Domain

Admins

* chrisheecho@kubeflow.org
* ewj@kubeflow.org
* jlewi@kubeflow.org
* sarahmaddox@kubeflow.org
* thea@kubeflow.org

## Kubeflow GCP org

This should be tied to the gsuite domain.

Admins

* jlewi@google.com
* ricliu@google.com

## DockerHub:

https://hub.docker.com/u/kubeflow

owners (docker ids):

* carmark@
* gaocege@
* jlewigoogle@
* k82cn@
* seedjeffwan@

### DockerHub Robot Accounts

user: kubeflowrobot
password:
 
 * Secret dockerhub-kubeflowrobot in GCP Secret Manager In Project kubeflow-admin

## Medium

https://medium.com/kubeflow

Editors

* @chrisheecho_78982
* @ankitbahuguna
* @jlewi
* @edd
* @thealamkin

TODO(jlewi): Are there owners/admins with higher privileges then editors?

For more info see: https://github.com/kubeflow/community/issues/316

## Netlify

We have the following netlify sites

* https://app.netlify.com/sites/competent-brattain-de2d6d/overview
  * This should be our main site
  * Prior to 1.0 we were creating new sites for every release see https://github.com/kubeflow/website/issues/1581
  * Refer to [releasing.md](https://github.com/kubeflow/kubeflow/blob/master/docs_dev/releasing.md#version-the-website) for
    more instructions


Access is granted through the Netlify kubeflow-team; current owners are

* jeremy@lewi.us
* ricliu@google.com
* saramaddoxmail@gmail.com

## Twitter

https://twitter.com/kubeflow

Root account:

username: kubeflow
password: 

 * This is stored in Google Secret Manager inside project kubeflow-admins

The following twitter accounts are linked as teammebers

* @aronchick
* @edd
* @jeremylewi
* @taylamkin

## Mailing List

https://groups.google.com/forum/#!members/kubeflow-discuss

Owners:

* abhishek@google.com
* ewj@google.com
* jlewi@google.com
* thealamkin@google.com

## Slack

kubeflow.slack.com


Workspace Owners:

* abhishek@google.com
* aronchick@gmail.com
* sarahmaddox@gmail.com
* thealamkin@google.com
* vishnuk@google.com


## Zoom

Owner:

* ewj@google.com

Admins 

* jlewi@google.com
* thealamkin@google.com

## DNS Domains

The following domains are currently owned and registered through Google

* kubeflow.ai
* kubeflow.cloud
* kubeflow.dev
* kubeflow.org
* kubeflow.io
* kubeflow.com

The nameservers for these domains are mapped to Google Cloud DNS in project
kubeflow-dns.
