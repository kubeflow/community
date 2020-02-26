# Guidelines for creating Docker images for Kubeflow applications

Authors: duselvar@cisco.com, jlewi@google.com, adselvaraj@cisco, jtf.github@gmail.com

## Objective

The purpose of this document is to outline a process for creating docker images maintained by our community for Kubeflow Applications.

The main goals are to: 

1. Establish a process around creating images for Kubeflow Applications.
1. Improve security of the images built for running Kubeflow Applications.

## Scope

This document is intended to cover container images of applications that are deployed in the
Kubernetes cluster as part of Kubeflow and in particular:

1. Custom resources and controllers
1. Web applications

This document is not intended to cover any image which is not deployed to the Kubernetes cluster.


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

#### Recommendation for Golang images

- It is recommended to use Golang 1.13+ images while building docker images as it contains critical security fixes for the packages net/http, crypto/dsa and net/textproto.

- While building Golang binaries in the build docker file, it is recommended to build with the below flags to ensure that the binary runs without needing to use `libc` based packages. This facilitates the use of distroless' `static` image as opposed to `base` image.
```
RUN CGO_ENABLED=0 GOOS=linux go build -o <output_binary> -ldflags "-w" -a .
```

### Selection of actual image

Kubeflow community recommends the usage of [distroless images](https://github.com/GoogleContainerTools/distroless) for building images for Kubeflow Applications.

This approach reduces the image's size to only what is required to run the application thereby reducing security risks.

The preference of distroless images to be chosen according to language is given by the table below:


| Programming Language or Framework  | Docker Image |
| ------------- | ------------- |
| Golang  | [gcr.io/distroless/static-debian10](gcr.io/distroless/static-debian10) |
| Python3  | [gcr.io/distroless/python3-debian10](gcr.io/distroless/python3-debian10) |
| NodeJS  | [gcr.io/distroless/nodejs](gcr.io/distroless/nodejs) |

#### Example image for Kubeflow

[Tf-operator distroless image](https://github.com/kubeflow/tf-operator/blob/master/build/images/tf_operator/Dockerfile) for Golang based binary serves as an example image for Kubeflow.

## Best Practices

It is recommended to use a CVE scanning tool to report vulnerabilities in the image being replaced and compare it with the report of the newer image. This is to ensure that the CVE count reduces with each update to an image.
