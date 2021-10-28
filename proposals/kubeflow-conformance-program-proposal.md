# Kubeflow Conformance Test

James Wu (james-jwu@)  
2021-07-29  
[link to Google doc](https://docs.google.com/document/d/1a9ufoe_6DB1eSjpE9eK5nRBoH3ItoSkbPfxRA0AjPIc/edit?resourcekey=0-IRtbQzWfw5L_geRJ7F7GWQ#)

# Overview

The [Kubeflow Project](https://github.com/kubeflow) is currently managed by different [Working Groups](https://github.com/kubeflow/community/blob/master/wg-list.md) whose composition represents a broad spectrum of industry and community. The Kubeflow trademark is owned by Google.   

The [Kubeflow Brand Guidelines](https://github.com/kubeflow/community/blob/master/KUBEFLOW_BRAND_GUIDELINES.pdf) was published in Mar. 2021. The guideline is broadly applicable to usage of Kubeflow trademark by products, events and publications. While the brand guidelines provide general guidance, it does not prescribe the definition of Kubeflow and what makes a distribution/application "Kubeflow" vs. not "Kubeflow".  

This document aims to define conformance criteria for the following usage of Kubeflow trademark:

-  For Kubeflow distribution - "Certified Kubeflow"
-  For Kubeflow application - TBD

The goal is to ensure these special usages of Kubeflow trademark meet common standards of interoperability, increase cohesiveness of the Kubeflow platform, promote customer confidence, reduce the burden of Kubeflow maintainers, and extend Kubeflow’s influence beyond the Kubeflow project.

# Certified Kubeflow (for Kubeflow Distribution)

**A conformant Kubeflow Distribution is certified to provide a set of core functionalities and API integration options.**

The tests will be designed in a way similar to [Kubernetes conformance program](https://github.com/cncf/k8s-conformance).  

The tests will be versioned. Each versioned certification is valid for 1 year. After 1 year, recertification against the latest version of the test will be required to maintain certification standing.

**Entitlement**

- Conformant distributions are entitled to refer to the distribution as "**Certified Kubeflow**". Example usage:
   - Appending “(Certified Kubeflow)” to the distribution name: e.g. AI-IS-FUN (Certified Kubeflow)
   - Reference the Certified Kubeflow designation in discussion with customers, or on public documentation
- Display a logo (to be designed) on the public website and documentation of the distribution
- Be listed under a partner web page under the Kubeflow project.
- The naming of the distribution still needs to follow [Kubeflow Brand Guidelines](https://github.com/kubeflow/community/blob/master/KUBEFLOW_BRAND_GUIDELINES.pdf).

The following are out of scope of the conformance tests:
1. Product quality and supportability

The test design is strongly influenced by Kubernetes conformance program, where a very narrow set of tests are established to verify key API functionality. Since the tests are versioned, it is hoped that unsupported distributions will fall out of conformance by discontinuing the certification with the latest test version.

2. Development and distribution channel

The test will not verify how the distribution is developed (e.g. in Kubeflow organization vs. outside), or how the distribution is made available to users. Such criteria are left to the Kubeflow organization to define and enforce.

## Example

Company X creates a distribution of Kubeflow and plans to name it "X Kubeflow Service". Company X tries to certify for Kubeflow conformance, which entails:

-  Install the distribution
-  Runs the Kubflow conformance test suite
-  Submits the test log as a PR to Kubeflow Trademark Team for approval.
-  Upon approval and following trademark guidelines, Company X changes the distribution name to "X service for Kubeflow", or "X Platform (Certified Kubeflow)"
-  Optionally, the distribution may be listed in a catalog on Kubeflow website

The conformance tests make sure "X service for Kubeflow" supports KFP and Metadata. Company X may include more applications (e.g. TFJob, Katib) in the distribution, but it does not affect the conformance standing of "X service for Kubeflow".

## First version of conformance

The first version of conformance aims to be inclusive of current components in Kubeflow organization. The number of tests are intentionally kept small to allow fast progress and iteration. We propose:
-  Each Kubeflow Working Group nominate <= 10 tests to be included in the conformance suite
   -  We recommend the candidate tests to be simple API acceptance tests that run reliably. Please keep in mind that the certification body is looking for a simple pass/fail to determine certification standing.
   -  There is no precedence for including UI in conformance tests. That said, we will experiment with options to include UI, most likely through self attestation and supporting evidence (e.g. screenshot or video). The details are TBD.
-  Each WG works with the conformance test team (currently staffed by Google) to include the nominated tests into the conformance suite.

**Example**: for Kubeflow Pipelines, the first version of conformance will be limited to V1 Pipeline Runtime conformance. A subset of tests outlined in Appendix A will be included.

# 

# Kubeflow Native (for Kubeflow Application)

**Kubeflow Application certification verifies that the application under test integrates well with Kubeflow.**

1. The application is a Kubernetes Application

Kubeflow is by definition “The Machine Learning Toolkit for Kubernetes”. There is no precise definition for “Kubernetes Application”, and Kubernetes does not have a conformance program for applications. For the purpose of Kubeflow certification, we propose “Kubernetes Application” means that the application is deployable via kubectl, kustomize or helm.

Verification is done by self-attestation. The application-under-test needs to include a clause in readme saying “This application is deployable in accordance with the Kubeflow Application Certification Program version 1.0”, with a link leading to the documentation of the conformance program.

We expect this test to evolve, due to the ambiguity of “Kubenetes Application”.

2. The application-under-test integrates well with Kubeflow.

The first version of the test verifies that the application is integrated with Kubeflow Pipelines. Pipeline and Metadata are the binding “glue” for other Kubeflow components. Metadata generation is automatic when Kubeflow Application conforms to standard Kubeflow Pipelines component interface.

**Entitlement**
- Conformant applications are entitled to refer to the application as “Kubeflow Native” or <TBD>. Example usage:
   - Appending “(Kubeflow Native)” to the distribution name: e.g. SUPER-TRAINER (Kubeflow Native)
   - Reference the Kubeflow Native designation in discussion with customers, or on public documentation
   - Display a logo (to be designed) on the public website and documentation of the application
- The application may be listed under an application catalog (to be created) under Kubeflow project.
- The naming of the application still needs to follow [Kubeflow Brand Guidelines](https://github.com/kubeflow/community/blob/master/KUBEFLOW_BRAND_GUIDELINES.pdf).

## Example

Company X creates a Kubernetes Custom Resource for model training, and wishes to certify the feature for Kubeflow Application. Company X needs to:

-  Create a Kubeflow Pipelines component for launching the custom resource, with inputs and outputs appropriately defined using parameters and artifacts. The component may be published as a Python function or YAML.
-  Add self-attestation to the readme file.
-  Runs conformance tool against the Python source, by specifying the source file, and the component function (in the case of Python function).
-  Submits the test results to Kubeflow Trademark Team for approval.
-  Upon approval, Company X may name the component "X Training for Kubeflow", "X Training <TBD>"

## Test principles

Kubeflow Application conformance test verifies the component function under test conforms to the Kubeflow Pipelines component definition. 

Proposed CLI:

```
$ kfp conformance verify-component --file=my_component.py --component_function=my_component

$ kfp conformance verify-component - file=my_component.yaml
```

The tests verify the component integrates well with the following:

-  Kubeflow Pipeline integration: a well defined component interface ensures the Kubeflow Application under test plays well with other Kubeflow Applications. The test will not try to verify functionality or code quality.
-  Metadata: Kubeflow Pipelines automatically records the input/output parameters and artifacts in metadata. The tests verify the component interfaces. Kubeflow Application candidates can optionally emit metadata, either by using output_metadata mechanism (to be explained), or some other mechanism added to KFP in the future. Kubeflow Application candidates are encouraged to log additional metadata to MLMD but are not required to do so.

## References

-  Prior [discussion](https://groups.google.com/g/kubeflow-discuss/c/d6whgEgror8) in Kubeflow community on Kubeflow conformance

# Appendix

   ## Pipeline tests

-  Pipeline runtime
   -  V1 conformance
      -  The tests use a designated version of KFP SDK to compile a set of pipelines and submit it to the distribution under test.

   -  V2 conformance
      -  The tests uses a designated version of KFP SDK that compiles pipeline to [IR](https://docs.google.com/document/d/1PUDuSQ8vmeKSBloli53mp7GIvzekaY7sggg6ywy35Dk/edit) (Intermediate Representation)
      -  The IR is submitted to the pipeline server to exercise and verify different KFP features.

   -  Below is a categorization of the features and is not meant to be exhaustive.
      -  Artifact and parameter passing
      -  Caching
      -  Executors: container / importer / resolver
      -  Control flow features: ParallelFor, conditional, exit handler
      -  A subset of Kubernetes features (e.g. secrets, volume)

-  Pipeline management
   -  Pipeline template management
   -  Pipeline run management (Get / Delete / Cancel / Archive / Retry)
   -  Recurring runs

## Metadata tests

-  Metadata lineage - pipeline runs must produce the correct lineage graph including
   -  Context
   -  Execution
   -  Artifact
   -  Event

-  Metrics - verifies metrics artifacts are produced
-  Metadata APIs (future work)

