{
  global: {},
  components: {
    // Component-level parameters, defined initially from 'ks prototype use ...'
    // Each object below should correspond to a component in the components/ directory
    backfill: {
      end_day: '2019-05-12',
      start_day: '2018-01-01',
    },
    devstats: {
      fqdn: 'devstats.kubeflow.org',
      issuer: 'letsencrypt-prod',
      tlsSecretName: 'grafana-tls',
    },
    "cert-manager": {
      acmeEmail: 'jlewi@google.com',
      acmeUrl: 'https://acme-v01.api.letsencrypt.org/directory',
      name: 'cert-manager',
      namespace: 'null',
    },
  },
}