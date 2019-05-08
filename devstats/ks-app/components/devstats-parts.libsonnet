{
  // The base directory where projects.yaml etc... can be found.
  // This should be a directory in a git repo that is cloned onto an NFS mounted volume.
  local configRepoRoot = "/mount/data/src/git_kubeflow-community/devstats/config",

  local nfsMountPath = "/mount/data",
  
  // Volumes and volumeMounts for nfs
  local volumeMounts = [
    {
      mountPath: nfsMountPath,
      name: "nfs",
    },
    {
      mountPath: "/etc/github",
      name: "gitdm-github-oauth",
    },
  ],

  local volumes = [
    {
      name: "nfs",
      persistentVolumeClaim: {
        claimName: "devstats-nfs",
      },
    },
    {
      name: "gitdm-github-oauth",
      secret: {
        secretName: "gitdm-github-oauth",
      },
    },
  ],

  // Prototypes
  all(params, env)::
    // The devstats DB is one of two postgress databases that we need. Its used for logs and other information.

    $.parts(params, env).postgreDb("devstatsdb", "devstats-postgres") +
    [
      $.parts(params, env).cli,
      $.parts(params, env).grafanaIngress,
      $.parts(params, env).certificate,
      $.parts(params, env).grafanaService,
      $.parts(params, env).grafanaDeploy,
      $.parts(params, env).grafanaServiceAccount,
    ],

  backfilljob(params, env)::
    [$.parts(params, env).backFillJob],

  syncCronJob(params, env)::
    [$.parts(params, env).syncCronJob],

  parts(params, env):: {
    local namespace = env.namespace,

    local devstatsImage = "gcr.io/devstats/devstats:v20190217-ed3e9c1-dirty-fdc649",
    local devStatsDbName = "devstatsdb",

    // Where to mount the projects config map
    local projectsMountPoint = "/etc/projects-volume",

    local fqdn = params.fqdn,

    // Environment variables to be set on various pods.
    // These control the devstats tools
    local devstatsEnv = [
      // The devstats scripts use variables with prefix "PG_"
      {
        name: "PG_HOST",
        value: devStatsDbName + "-0." + devStatsDbName + "." + namespace + ".svc.cluster.local",
      },
      {
        name: "PG_DB",
        value: "kubeflow",
      },
      {
        name: "PG_PASS",
        value: "password",
      },
      {
        name: "PG_PASS_ROLE",
        value: "ro_user",
      },
      // Postgres uses slightly different variable names
      // https://www.postgresql.org/docs/9.5/libpq-envars.html
      // Keep these in sync with PG_values.
      {
        name: "PGHOST",
        value: devStatsDbName + "-0." + devStatsDbName + "." + namespace + ".svc.cluster.local",
      },
      {
        name: "PGDATABASE",
        value: "kubeflow",
      },
      {
        name: "PGUSER",
        value: "gha_admin",
      },
      {
        name: "PGPASSWORD",
        value: "password",
      },
      // More environment variables used by devstats scripts
      {
        // TODO(jlewi): Is this supposed to match the name in projects.yaml?
        name: "GHA2DB_PROJECT",
        value: "kubeflow",
      },
      {
        // Location of projects.yaml file. This will be mounted from NFS
        name: "GHA2DB_PROJECTS_YAML",
        value: "projects.yaml",
      },
      {
        // The directory where ./get_repos will check out Kubeflow repos to
        // We put this on NFS so its resilient.
        name: "GHA2DB_REPOS_DIR",
        value: nfsMountPath + "/devstats_repos",
      },
      {
        // TODO(jlewi): We could probably use the other secret that contains the client id and secret in addition to oauth.
        name: "GHA2DB_GITHUB_OAUTH",
        valueFrom: {
          secretKeyRef: {
            name: "github-oauth",
            key: "github-oauth",
          },
        },
      },
      # We set the environment because of this issue
      # https://stackoverflow.com/questions/17031651/invalid-byte-sequence-in-us-ascii-argument-error-when-i-run-rake-dbseed-in-ra
      { 
        name: "RUBYOPT",
        value: "-KU -E utf-8:utf-8",
      },
    ],

    // Create components for a postgre database.
    postgreDb(name, diskName):: [
      // Service
      {
        apiVersion: "v1",
        kind: "Service",
        metadata: {
          labels: {
            app: name,
          },
          name: name,
          namespace: namespace,
        },
        spec: {
          clusterIP: "None",
          ports: [
            {
              port: 5432,
            },
          ],
          selector: {
            app: name,
          },
        },
      },  // service

      // Stateful set
      {
        apiVersion: "apps/v1",
        kind: "StatefulSet",
        metadata: {
          name: name,
          namespace: namespace,
        },
        spec: {
          replicas: 1,
          selector: {
            matchLabels: {
              app: name,
            },
          },
          serviceName: name,
          template: {
            metadata: {
              labels: {
                app: name,
              },
            },
            spec: {
              containers: [
                // The postgres container DB.
                {
                  env: [
                    // POSTGRES_USER" and "POSTGRES_PASSWORD" are  used
                    // by the startup script postgre-docker-entrypoint.sh.
                    //
                    // Looks like post gres uses different values; see
                    // https://www.postgresql.org/docs/9.5/libpq-envars.html.
                    {
                      name: "POSTGRES_USER",
                      value: "postgres",
                    },
                    {
                      name: "POSTGRES_PASSWORD",
                      value: "password",
                    },
                    {
                      // This is the default DB; it is created on container startup if it doesn't
                      // exist by postgre-docker-entrypint.
                      // I(jlewi@) think postgres might need some sort of default DB to exist.
                      // But this is not the DB used with Kubeflow.
                      // That db is named kubeflow.
                      name: "POSTGRES_DB",
                      value: "postgres",
                    },
                    // https://www.postgresql.org/docs/9.0/app-postgres.html
                    {
                      name: "PGDATA",
                      value: "/mount/data/postgresql/",
                    },
                  ],
                  image: devstatsImage,
                  name: "postgres",
                  command: [
                    "/usr/local/bin/postgre-docker-entrypoint.sh",
                    "postgres",
                  ],
                  ports: [
                    {
                      containerPort: 5432,
                    },
                  ],
                  securityContext: {
                    // Run as the postgres user and group.
                    // Keep in sync with the values used in the container.
                    runAsUser: 1000,
                    runAsGrou: 1000,
                  },
                  volumeMounts: volumeMounts,
                },  // Postgres container
              ],  // containers
              volumes: volumes,
            },
          },
        },
      },  //stateful set
    ],  // postgreDb

    // Create a pod running as a stateful set that we can use
    // to execute commands manually.
    //
    // We use a PVC for /home so that data will persist across reboots.
    cli:: {
      apiVersion: "apps/v1",
      kind: "StatefulSet",
      metadata: {
        name: "devstats-cli",
        namespace: namespace,
        labels: {
          app: "devstats-cli",
        },
      },
      spec: {
        replicas: 1,
        selector: {
          matchLabels: {
            app: "devstats-cli",
          },
        },
        template: {
          metadata: {
            labels: {
              app: "devstats-cli",
            },
          },
          spec: {
            containers: [
              {
                command: [
                  "tail",
                  "-f",
                  "/dev/null",
                ],
                env: devstatsEnv,
                image: devstatsImage,
                name: "devstats",
                workingDir: configRepoRoot,
                volumeMounts: [
                  {
                    mountPath: "/home",
                    name: "cli-home",
                  },
                ] + volumeMounts,
              },
            ],
            terminationGracePeriodSeconds: 10,
            volumes: volumes + [
              // Use a PD for /home.
              {
                name: "cli-home",
                persistentVolumeClaim: {
                  claimName: "cli-home",
                },
              },
            ],
          },
        },
      },
    },  // cli

    // A K8s job to backfill
    backFillJob:: {
      apiVersion: "batch/v1",
      kind: "Job",
      metadata: {
        name: "backfill-job",
        namespace: namespace,
      },
      spec: {
        template: {
          spec: {
            containers: [
              {
                command: [
                  "gha2db",
                  params.start_day,
                  "00",
                  params.end_day,
                  "23",
                  "kubeflow",
                ],
                env: devstatsEnv,
                image: devstatsImage,
                name: "devstats",
                volumeMounts: volumeMounts,
              },
            ],
            restartPolicy: "OnFailure",
            terminationGracePeriodSeconds: 10,
            volumes: volumes,
          },
        },  // template
      },
    },  // backFillJob

    // A K8s cron job to sync the DB.
    syncCronJob:: {
      apiVersion: "batch/v1beta1",
      kind: "CronJob",
      metadata: {
        name: "devstats-sync",
        namespace: namespace,
      },
      spec: {
        schedule: "@hourly",
        jobTemplate: {
          spec: {
            template: {
              spec: {
                containers: [
                  {
                    command: [
                      "devstats",
                    ],
                    env: devstatsEnv,
                    image: devstatsImage,
                    name: "devstats",
                    workingDir: configRepoRoot,
                    volumeMounts: volumeMounts,
                  },
                ],
                restartPolicy: "OnFailure",
                terminationGracePeriodSeconds: 10,
                volumes: volumes,
              },
            },
          },
        },  // template
      },
    },  // syncCronJob

    certificate:: {
      apiVersion: "certmanager.k8s.io/v1alpha1",
      kind: "Certificate",
      metadata: {
        name: params.tlsSecretName,
        namespace: namespace,
      },

      spec: {
        secretName: params.tlsSecretName,
        issuerRef: {
          name: params.issuer,
        },
        commonName: params.fqdn,
        dnsNames: [
          params.fqdn,
        ],
        acme: {
          config: [
            {
              http01: {
                ingress: "grafana",
              },
              domains: [
                params.fqdn,
              ],
            },
          ],
        },
      },
    },  // certificate

    grafanaIngress:: {
      apiVersion: "extensions/v1beta1",
      kind: "Ingress",
      metadata: {
        name: "grafana",
        namespace: namespace,
        annotations: {
          "kubernetes.io/ingress.global-static-ip-name": "devstats",
          "kubernetes.io/tls-acme": "true",
          // TODO(jlewi): We should automatically redirect users
          // to the https site. We could do this by using a custom default
          // backend.
        },
      },
      spec: {
        rules: [
          {
            host: params.fqdn,
            http: {
              paths: [
                {
                  backend: {
                    serviceName: "grafana",
                    servicePort: 3000,
                  },
                  path: "/*",
                },
              ],
            },
          },
        ],
        tls: [
          {
            hosts: [
              params.fqdn,
            ],
            secretName: params.tlsSecretName,
          },
        ],
      },
    },  // ingress

    grafanaService:: {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        name: "grafana",
        namespace: namespace,
      },
      spec: {
        ports: [
          {
            name: "http",
            port: 3000,
            protocol: "TCP",
          },
        ],
        selector: {
          app: "grafana",
        },
        type: "NodePort",
      },
    },

    grafanaDeploy:: {
      apiVersion: "extensions/v1beta1",
      kind: "Deployment",
      metadata: {
        name: "grafana",
        namespace: namespace,
      },
      spec: {
        replicas: 1,
        template: {
          metadata: {
            labels: {
              app: "grafana",
            },
          },
          spec: {
            containers: [
              {
                env: [
                  // TODO(jlewi): Grafana allows data sources to be managed from
                  // YAML files; we should do that so it doesn't have to be configured
                  // via UI. http://docs.grafana.org/administration/provisioning/#datasources

                  // Grafana allows all values in the .ini file to be
                  // overwritten by environment variables.
                  // see http://docs.grafana.org/administration/provisioning/
                  //
                  // Override the location used for data so we can use a location
                  // that corresponds to a PD.
                  {
                    name: "GF_PATHS_DATA",
                    value: "/mount/data/grafana",
                  },

                  // Override the location used for provisioning so we
                  // can provide the sources via a configmap.
                  // See http://docs.grafana.org/administration/provisioning/#dashboards
                  {
                    name: "GF_PATHS_PROVISIONING",
                    // Should be a directory containing providers.yaml
                    value: configRepoRoot + "/grafana/provisioning",
                  },

                  // Override the admin password
                  {
                    name: "GF_SECURITY_ADMIN_PASSWORD",
                    valueFrom: {
                      secretKeyRef: {
                        name: "grafana",
                        key: "admin_password",
                      },
                    },
                  },

                  // Allow anyonmous access
                  {
                    name: "GF_AUTH_ANONYMOUS_ENABLED",
                    value: "true",
                  },
                ],
                image: "grafana/grafana",
                imagePullPolicy: "IfNotPresent",
                name: "grafana",
                ports: [
                  {
                    containerPort: 3000,
                  },
                ],
                volumeMounts: volumeMounts,
              },  // grafana
            ],  // containers
            volumes: volumes,
          },
        },
      },
    },  // grafanaDeploy

    grafanaServiceAccount: {
      apiVersion: "v1",
      kind: "ServiceAccount",
      metadata: {
        name: "grafana",
        namespace: namespace,
      },
    },
  },  // parts
}
