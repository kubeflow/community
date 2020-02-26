
# Guidelines for creating docker images for Kubeflow applications

Authors: duselvar@cisco.com, jlewi@google.com

## Objective

The purpose of this document is to outline a process of creating docker images maintained by our community for Kubeflow Applications.

The main goals are to: 

1. Establish a process around creating images for Kubeflow Applications.
1. Improve security of the images built for running Kubeflow Applications.

## Scope


## Process

Using [Multi-staged builds](https://docs.docker.com/develop/develop-images/multistage-build/) you can separate the build process to a separate build image and copy the binaries generated from the build stage to the actual image.

### Selection of build image

The recommended build images for each of the programming languages are listed below:

| Programming Language or Framework  | Docker Image |
| ------------- | ------------- |
| Golang  | [Golang Docker Image](https://hub.docker.com/_/golang) |
| Python3  | [Python Docker Image](https://hub.docker.com/_/python) |
| NodeJS  | [NodeJS Docker Image](https://hub.docker.com/_/node/) |

If your language or framework is not covered within these above recommendations, it is recommended to use the official images for the respective language or framework.

#### Golang images

It is recommended to use golang 1.13+ images while builing docker images as it contains critical security fixes net/http, crypto/dsa and net/textproto packages.

### Selection of actual image


#### Example image for Kubeflow

## Best Practices