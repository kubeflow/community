# Experiment tracking

This document is design proposal for new service within Kubeflow - experiment tracking. Need for tool like this was
expressed in multiple issues and discussions.

## What is experiment tracking

Production machine learning systems may generate huge amount of models. We want the ability to compare multiple training runs and find the model that provides the best metrics. When trying different combinations of parameters to find the optimal parameters we may produce multiple models. The amount of training jobs are generated automatically (for example via hyperparameter tuning or retraining as new data becomes available) can quickly can grow to thousands of models. It's important to be able to navigate this, select those with best performance, examine them in detail and be able to compare them. Once we select the best model we can move on to the next step which is inference. We need to track things like model location (on S3, GS or disk), model metrics (end accuracy, P1 score, whatever experiment requires) or logs location. Our data scientists may require isolation as they are working on different experiments so they should have a view/ui that lets them find the experiment quickly.

## Example user stories
* I'm a data scientist working on a problem. I'm looking for easy way to compare multiple training jobs with multiple sets of hyperparameters. I would like to be able to select top 5 jobs measured with P1 score and examine which model architecture, hyperparameters, dataset and initial state contributed to this score. I would want to compare these 5 together in highly detailed way (for example via tensorboard). I would like rich UI to navigate models without need to interact with infrastructure.
* I'm part of big ML team in company. Our whole team works on single problem (for example search) and every person builds their models. I'd like to be able to compare my models with others. I want to be safe that nobody will accidentally delete model I'm working on.
* I'm cloud operator in ML team. I would like to take current production model (architecture+hyperparams+training state) and retrain it with new data as it becomes available. I would want to run suite of tests and determine if new model performs better. If it does, I'd like to spawn tf-serving (or seldon) cluster and perform rolling upgrade to new model.
* I'm part of highly sophisticated ML team. I'd like to automate retraining->testing->rollout for models so they can be upgraded nightly without supervision.
* I’m part of the ML team in company. I would like to be able to track my parameters used to train an ML job and track the metrics produced. I would like to have isolation so I can find the experiments I worked on. I would like the ability to compare multiple training rules side by side and pick the best model. Once I select the best model I would like to deploy that model to production. I may also want to test my model with historical data to see how well it performs and maybe roll out my experiment to a subset of users before fully rolling out to all users.


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
for this problem and allow easy spawn of tensorboard instance for selected models. We might need to find alternative for scikit-learn. Perhaps we can try mlflow for scikit-learn.


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

* Tensorboard - Wasn't meant for large number of models. It's better for very detailed examination of smaller number of models. Uses tf.Event files
* MLFlow - One of the cons for this is that experiment metadata is stored on disk. In kubernetes may require persistent volumes. A better approach would be to store metadata in a database. Pros, can store models in multiple backends (S3, Azure Cloud Storage and GCS among other things)
* ModelDB - Requires mongodb which is problematic
* StudioML - Also uses FS/object store as backend, which have same querying considerations as MLFlow

All 3 have some subset of features, but none of them seems to be designed for scale we're aiming for. They don't have integration with Kubeflow as well.

## Authors

* inc0
* zmhassan - Zak Hassan
