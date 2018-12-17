{
  global: {
    // User-defined global parameters; accessible to all component and environments, Ex:
    // replicas: 4,
  },
  components: {
    // Component-level parameters, defined initially from 'ks prototype use ...'
    // Each object below should correspond to a component in the components/ directory
    backfill: {  
      end_day: "2018-04-17",
      start_day: "2018-01-01",
  	},
    devstats: {    
      fqdn: "devstats.kubeflow.org",    
      issuer: "letsencrypt-prod",
      tlsSecretName: "grafana-tls",
    },
    "cert-manager": {
      acmeEmail: "jlewi@google.com",
      acmeUrl: "https://acme-v01.api.letsencrypt.org/directory",
      name: "cert-manager",
      namespace: "null",
    },
  },
}
