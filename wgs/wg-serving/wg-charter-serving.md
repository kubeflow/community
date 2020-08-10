# WG Serving Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

WG Serving covers deploying models in production on Kubeflow. The scope of the problems we are trying to cover are

- Cost: Is the model over or under scaled? Are resources being used efficiently?
- Monitoring:Are the endpoints healthy? What is the performance profile and request trace? 
- Rollouts:Is this rollout safe? How do I roll back? Can I test a change without swapping traffic?
- Protocol Standards:How do I make a prediction? GRPC? HTTP? Kafka?
- Frameworks:How do I serve on Tensorflow? XGBoost? Scikit Learn? Pytorch? Custom Code? 
- Features:How do I explain the predictions? What about detecting outliers and skew? Bias detection? Adversarial Detection
- Batch: How do I handle batch predictions? 
- Data Plane: How do I leverage standardized Data Plane protocol so that I can move my model across MLServing platforms?
- Custom Processors: How do I wire up custom pre and post processing

### In scope

#### Code, Binaries and Services

- APIs used for deploying models with multiple runtimes pre-integrated (TFServing, Nvdia Triton (GPU optimization), ONNX Runtime, SKLearn, PyTorch, XGBoost, Custom models)
- Serverless ML Inference and Autoscaling: Scale to zero (with no incoming traffic) and Request queue based autoscaling 
- Canary and Pinned rollouts: Control traffic percentage and direction, pinned rollouts
- Pluggable pre-processor/post-processor via Transformer: Gives capabilities to plug in pre-processing/post-processing - - implementation, control routing and placement (e.g. pre-processor on CPU, predictor on GPU)
- Pluggable analysis algorithms: Explainability, Drift Detection, Anomaly Detection, Adversarial Detection enabled by Payload Logging (built using CloudEvents standardized eventing protocol) 
- Batch Predictions: Batch prediction support for ML frameworks (TensorFlow, PyTorch, ...)
- Integration with existing monitoring stack around Knative/Istio ecosystem: Kiali (Service placements, traffic and graphs), Jaeger (request tracing), Grafana/Prometheus plug-ins for Knative)
- Multiple clients: kubectl, Python SDK, Kubeflow Pipelines SDK
- Standardized Data Plane V2 protocol for prediction/explainability
- MMS: Multi-Model-Serving for serving multiple models per custom KFService instance
- Multi-Model-Graphs and Pipelines: Support chaining multiple models together in a Pipelines
- gRPC Support for all Model Servers
- Support for multi-armed-bandits

#### Cross-cutting and Externally Facing Processes

- Coordinating with WG Pipeline to make sure models can be deployed and rolled out  with pipelines
- Coordinating with release teams to ensure that the serving features can be released properly

### Out of scope

- APIs used for running distributed training, machine learning pipelines etc.

## Roles and Organization Management

This WG follows adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].

### Subproject Creation

WG Technical Leads

[wg-governance]: ../wg-governance.md
[wg-subprojects]: https://github.com/Kubeflow/community/blob/master/wg-YOURWG/README.md#subprojects
[Kubeflow Charter README]: https://github.com/Kubeflow/community/blob/master/committee-steering/governance/README.md