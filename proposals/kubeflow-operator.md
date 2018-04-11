
# Motivation
As Kubeflow supports more than one framework, there would be use for overarching control plane to help with common machine learning
steps like uploading code or training model. This control plane then could expose API that can be leveraged by various programming languages, CLI,
plugins etc.

# Goals
Create service deployed as part of kubeflow-core that would expose API that then could be consumed by swagger to generate client libs and CLI tool.

# Use cases

## Easy start

I am data scientist. I want to setup Kubeflow easily without a lot of Kubernetes experience required. I would like to use easily replicable and well documented method to deploy Kubeflow on existing cluster. After that I want to have fully featured environment to help me with model development and deployment.

## Production data science

We are team of data scientists and we need to have access to fully featured environment that will help us with production use cases. We need tools that will allow us to work on multiple models, develop them (manually and automatically like with auto hyperparameter tuning), compare their performance and ultimately deploy to production (including rolling, no-ping-lost upgrade).

## Multi tenant environment

I am cloud operator and I need to provide multiple, fully featured, kubeflow environments for various teams dealing with different ML problems. Teams should have access restricted (with RBAC) to their environments.

# Design

## Environment

Environment is main, overarching resource in Kubeflow. It would contain configuration like common storage backend. One environment would correspond to one Kubernetes namespace and one KSonnet app. Environment operations would be superuser-level operations.

### Multitenancy over environments

Environment will be main user permission separator. While creating environment, because every environment resources would live in dedicated namespace, operator will be able to create RBAC role bindings that limits users to access only this namespace.

At the same time, users with access to this namespace would be able to manage resources within it, like spawning TFJobs within it.

### Each environment is separate ksonnet app

By creating an environment, operator effectively spawn whole set of Kubeflow resources that can are tracked as CRD. This CRD would hold all environment-specific variables like common S3/GS bucket for all the resources. Operator can prepare template environment to hold all configuration which is common to all environments on this setup, like basic storage or network infrastructure.

Namespace, in which ksonnet app will run, should follow predefined (and configurable) name schema for easier tracking (for example kubeflow-%envname).

### Environment as context for CLI

With CLI we can provide mechanisms to set default environment (for example `kf env use foo`). "Using" environment would be default way of how data scientist would interact with Kubeflow.
After setting active environment, shortcut commands becomes available, like `kf jupyer` would create port-forwarding to jupyterhub within this environment and output direct link to access it.
We could also provide toolset to quickly access things like pachyderm pipelines or tensorboard instance specific to all models within same environment.

### Benefits of using environment

Main benefit for separating kubeflow into environments managed by cloud operators will be abstracting knowledge of underlying infrastructure from data scientists. Expectation would be that cloud operator would define user access rights, infrastructure setup etc and provide easy-to-configure setup for data scientists to use from their machines (just wget kf binary and put this file in your home directory and you're done!).

We could also provide low-requirement environment template for new users to quickly bootstrap their first Kubeflow. We could use things like bootsrapper application to inspect existing environment and draft this template, that could then be edited (`kubectl edit configmap kubeflow-evironment-template`?) before calling kf env create.

# Implementation

## Using kubeless functions

One of ideas how to implement API is to provide set of kubeless functions that would perform required actions. All these function definitions would be gathered in one (or many) yaml file hosted in kubeflow repository. That would make installation of kubeflow logic as easy as `kubectl create -f https://url-to-yaml`. Another step would be to download pre-compiled kf binary that would provide easy way to interact with these functions.
