# Adoption of Feast Feature Store in Kubeflow

## **Authors**

Francisco Javier Arceo (Red Hat)  
Shuchu Han (Capital One)

## **Motivation**

Ref GitHub issue: [https://github.com/kubeflow/community/issues/804](https://github.com/kubeflow/community/issues/804)

[Feast](https://github.com/feast-dev/feast) is a project aimed at simplifying the development, testing, and deployment of proprietary data in AI/ML applications. 

[Feast](https://github.com/feast-dev/feast) helps ML platform/MLOps teams with DevOps experience productionize real-time models. Feast also helps these teams build a feature platform that improves collaboration between data engineers, software engineers, machine learning engineers, and data scientists.

* For Data Scientists: Feast is a tool where you can easily define, store, and retrieve your features for both model development and model deployment. By using Feast, you can focus on what you do best: build features that power your AI/ML models and maximize the value of your data.      
    
* For MLOps Engineers: Feast is a library that allows you to connect your existing infrastructure (e.g., online database, application server, microservice, analytical database, and orchestration tooling) that enables your Data Scientists to ship features for their models to production using a friendly SDK without having to be concerned with software engineering challenges that occur from serving real-time production systems. By using Feast, you can focus on maintaining a resilient system, instead of implementing features for Data Scientists.      
    
* For Data Engineers: Feast provides a centralized catalog for storing feature definitions, allowing one to maintain a single source of truth for feature data. It provides the abstraction for reading and writing to many different types of offline and online data stores. Using either the provided Python SDK or the feature server service, users can write data to the online and/or offline stores and then read that data out again in either low-latency online scenarios for model inference, or in batch scenarios for model training.  
    
* For AI Engineers: Feast provides a platform designed to scale your AI applications by enabling seamless integration of richer data and facilitating fine-tuning. With Feast, you can optimize the performance of your AI models while ensuring a scalable and efficient data pipeline.

Feast project boasts a substantial user base with [615 users](https://github.com/feast-dev/feast/network/dependents), [271 contributors](https://github.com/feast-dev/feast/graphs/contributors), and has 6.8k stars. Feast has a long history with Kubeflow, as an [add-on](https://www.kubeflow.org/docs/external-add-ons/feast/introduction/) and previously included in the manifest dating back to [March of 2021](https://github.com/kubeflow/manifests/pull/1755). There are many more organizations using it than the reported [8 in the Adopters file](https://github.com/feast-dev/feast/blob/6a1c1029b5462aaa42c82fdad421176ad1692f81/community/ADOPTERS.md?plain=1#L4). This can be validated by the [1,000+ forks](https://github.com/feast-dev/feast/forks). 

The motivation for this donation is that the current maintainers have to invest their time into managing the Feast project social channels and community, rather than on maintaining and enhancing the technical project. Given Feast’s history with Kubeflow and Tecton no longer supporting Feast, Kubeflow is likely the best long-term home for an open source feature store.

The current maintainers have no plan to leave the project and believe this will only increase its impact in the open source AI community

## **Benefits for Kubeflow**

We believe there are at least 6 key benefits:

1\. Incorporating Feast into Kubeflow (and the manifest) will help formally fill a needed gap for Kubeflow in the [AI/ML Lifecycle](https://github.com/user-attachments/assets/400a7170-2bec-4975-8132-a1b6e9006273).  

![][diagrams/aiml_lifecycle.png]

2\. It will also allow the Data WG to have an answer for the online serving of features. Additionally, this will nicely complement the Spark Operator as [Feast supports batch and stream processing using Spark as an offline store](https://docs.feast.dev/reference/offline-stores/spark).

3\. The Feast community is healthy and the users will further grow the Kubeflow community.

4\. Feast is expanding its scope to support Generative AI and RAG as a first-class citizen (retrieval/vector search in particular), which will help ensure Kubeflow has a solution for RAG.

5\. With the inclusion of Feast, we can provide end-to-end demos of development and production AI/ML and we can also provide suggested patterns for stitching the Kubeflow products together so that MLOps engineers, ML Engineers, and AI engineers can be impactful immediately after deploying Kubeflow.

6\. We are just as committed to Feast as we have ever been and we believe this will meaningfully enhance Kubeflow and result in Kubeflow getting the benefit of my contributions and the contributions of the Feast community.

Beyond the benefits to Kubeflow, I believe it will provide significant benefits to Feast in growing our community and embedding ourselves in a complete platform. This will also allow both communities (particularly Data Scientists/MLEs) to benefit from the GenAI/LLM/NLP work that I have been doing (see here: [\#4964](https://github.com/feast-dev/feast/issues/4964) and [\#4364](https://github.com/feast-dev/feast/issues/4364)).

As clear in the [Kubeflow User Survey](https://15905978862850875460.googlegroups.com/attach/150ca032927e6/'22%20Kubeflow%201.6%20User%20Survey%20-%20initial%20results.pdf?part=0.1.1&view=1&view=1&vt=ANaJVrFmCCfq8rEbnzakW7JKVPbTl1nhLDckzg79h1xmup5qc_c3rftVy1ne7tkCUMf5pUOfS3aMEXHfKEKeEVwV1TtdQOnvx3XMHYZ2uQHv-70K5CRyV0M), Feast serves a critical and challenging need: feature engineering and feature serving.

![][diagrams/kubeflow_feast.png]
![][diagrams/kubeflow_feature_engineering.png]

#### **Kubeflow Working Group Data**

As mentioned, Feast will also allow the [Data WG](https://github.com/kubeflow/community/pull/673) to have an answer for the online serving of features and will nicely complement the Spark Operator as [Feast supports batch and stream processing using Spark as an offline store](https://docs.feast.dev/reference/offline-stores/spark).

The scope of this WG is to provide guidelines for AI/ML users to run data preparation tools such as [Spark](https://spark.apache.org/), [Dask](https://www.dask.org/), [Ray](https://docs.ray.io/en/latest/) on Kubernetes, [Model Registry](https://github.com/kubeflow/kubeflow/issues/7396), and PIpelines can be a part of the **Data WG** scope.

## **Maintainers**

The following maintainers are committed to maintain Spark Operator under Kubeflow GitHub org to track issues, do releases, merge PRs.

* Francisco Javier Arceo (Red Hat)  
* Shuchu Han (Capital One)

## **Migration Plan**

#### GitHub Repository

The Feast repository is going to migrate to a new repository under Kubeflow GitHub org. That will allow us to save GitHub history (Issues, PRs, Commits).

* Current Repository: [https://github.com/feast-dev/feast](https://github.com/feast-dev/feast)  
* New Repository: [https://github.com/kubeflow/feast](https://github.com/kubeflow/feast)

#### API Changes

Currently, Feast has its own [APIs group for CR](https://github.com/feast-dev/feast/blob/6a1c1029b5462aaa42c82fdad421176ad1692f81/infra/feast-operator/api/v1alpha1/groupversion_info.go#L29).

Maintainers are going to decide if APIs should be renamed to \`kubeflow.org\` to keep it consistent with other Kubeflow APIs.

#### Documentation

Documentation is currently located in [GitBook](https://docs.feast.dev/) section. In the future we can add but not migrate docs to [the Kubeflow Website](https://www.kubeflow.org).

## **Other Solutions**

* [Feathr](https://github.com/feathr-ai/feathr)


