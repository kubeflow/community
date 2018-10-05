# Experiment tracking

This document is design proposal for new service within Kubeflow - experiment tracking. Need for tool like this was
expressed in multiple issues and discussions.

## What is experiment tracking

Production machine learning systems can generate huge amount of models. Every training pass can produce at least one, potentially multiple models.
If training jobs are generated automatically (for example via hyperparameter tuning or retraining as new data becomes available) this can quickly become
thousands of models. It's important to be able to navigate this, select those with best performance, examine them in detail and setup inference cluster
out of them. We need to track things like model location (on S3, GS or disk), model metrics (end accuracy, P1 score, whatever experiment requires) or logs location.

## Scale considerations

We need to support scale in tens of thousands of models. Potentially adding garbage collection above this. Within this scale we need to be able to quickly select best models
for particular problem.

## Model provenance

Another feature commonly asked for is model provenance. It's crucial to be able to reproduce results. For every model we need to record:

* Inital state, whether it's random weights or based on preexisting models
* Dataset used for training
* Dataset used for testing
* Feature engineering pipeline used
* Katib study id
* Model architecture (code used)
* Hyperparameters

Part of it can be solved by integration with Pachyderm.

## Model performance

To be able to pick best model for problem, we need to record metrics. Metrics can differ problem to problem, but we can support single number as quality weight
(user can define this number per experiment, whether it's accuracy, p1 score etc). We need to support very efficient queries using this metric.

## Model introspection

For selected models we should be able to setup model introspection tools, like Tensorboard.
Tensorboard provides good utility, allows comparison of few models and recently it was announced that it will integrate with pytorch. I think it's reasonable to use Tensorboard
for this problem and allow easy spawn of tensorboard instance for selected models. We might need to find alternative for scikit-learn.

## Inference cluster setup

For best model, we should easily spawn inference cluster. We should support tf-serving and Seldon.

## Integration with TFJob and Katib

It should be very easy, even automatic, to make entry to experiment tracking from TFJob. TF operator should be tightly integrated with it
and Katib should be able to both read models and write new ones.

Katib workflow could look like this:

Get study hyperparameter space -> select all existing model for study_id -> find out which hyperparameter combination is missing -> create relevant training jobs and add records to experiment tracking.

## UI

It's very important to provide good UI that allows easy model navigation and most of features listed via button click:

* Examine in tensorboard
* Train with new data
* Spawn inference cluster
* Run tests
* Show model provenance pipeline

## Alternatives

* Tensorboard
* MLFlow
* ModelDB

All 3 have some subset of features, but none of them seems to be designed for scale we're aiming for. They don't have integration with Kubeflow as well.

## Authors

* inc0
