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

# Kubeflow Distribution

A conformant Kubeflow Distribution is certified to provide a set of core functionalities and API integration options. A core set of these features are listed in the "[Pipeline tests](#heading=h.71p7gyy4tf5d)" and "[Metadata tests](#heading=h.wc7nytwk964f)'' sections.  
At the high level, the tests certifies that Kubeflow Pipeline and Metadata are part of the distribution, and exposes a standard set of APIs. Pipeline and Metadata and the binding "glue" for other Kubeflow components. With open standards for certifying Kubeflow Applications (see next section), the Kubeflow conformance criteria gives more flexibility to Kubeflow distributors to provide customization.   
The tests will be designed in a way similar to [Kubernetes conformance program](https://github.com/cncf/k8s-conformance).  
The tests will be implemented in stages.  
Conformant distributions is entitled to refer to the distribution as "Certified Kubeflow". The distribution can be listed under a partner page under the Kubeflow project. The naming of the distribution still needs to follow [Kubeflow Brand Guidelines](https://github.com/kubeflow/community/blob/master/KUBEFLOW_BRAND_GUIDELINES.pdf).

## Example

Company X creates a distribution of Kubeflow and plans to name it "X Kubeflow Service". Company X tries to certify for Kubeflow conformance, which entails:

-  Install the distribution
-  Runs the Kubflow conformance test suite
-  Submits the test log as a PR to Kubeflow Trademark Team for approval.
-  Upon approval and following trademark guidelines, Company X changes the distribution name to "X service for Kubeflow", or "X Platform (Certified Kubeflow)"
-  Optionally, the distribution may be listed in a catalog on Kubeflow website

The conformance tests make sure "X service for Kubeflow" supports KFP and Metadata. Company X may include more applications (e.g. TFJob, Katib) in the distribution, but it does not affect the conformance standing of "X service for Kubeflow".

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

## First version of conformance

The first version of conformance will be limited to V1 Pipeline Runtime conformance.

# 

# Kubeflow Application

Kubeflow Application certification verifies the application-under-test can integrate well with other Kubeflow Applications. Metadata generation is automatic when Kubeflow Application conforms to standard Kubeflow Pipelines component interface.  
Kubeflow Application is entitled to refer to the application as "Kubeflow Native" or <TBD>. The application may be listed under an application catalog (to be created) under Kubeflow project. The naming of the application still needs to follow [Kubeflow Brand Guidelines](https://github.com/kubeflow/community/blob/master/KUBEFLOW_BRAND_GUIDELINES.pdf).  
NOTE: existing projects in Kubeflow org do not require certification.

## Example

Company X creates a Kubernetes Custom Resource for model training, and wishes to certify the feature for Kubeflow Application. Company X needs to:

-  Create a Kubeflow Pipelines component for launching the custom resource, with inputs and outputs appropriately defined using parameters and artifacts. The component may be published as a Python function or YAML.
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
