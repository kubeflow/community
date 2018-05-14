local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["cert-manager"];
local k = import "k.libsonnet";
local certManager = import "kubeflow/core/cert-manager.libsonnet";

// updatedParams uses the environment namespace if
// the namespace parameter is not explicitly set
local updatedParams = params {
  namespace: if params.namespace == "null" then env.namespace else params.namespace,
};

certManager.parts(updatedParams.namespace).certManagerParts(params.acmeEmail, params.acmeUrl)
