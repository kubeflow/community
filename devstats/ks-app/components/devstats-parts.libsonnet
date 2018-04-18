{
  // Prototypes
  all(params, env)::
    // The devstats DB is one of two postgress databases that we need. Its used for logs and other information.
    $.parts(params, env).postgreDb("devstatsdb", "devstatsdb-data") +
    [
      $.parts(params, env).cli,
      $.parts(params, env).influxdbService,
      $.parts(params, env).influxdbStatefulSet,
      $.parts(params, env).projectsConfigMap,
      $.parts(params, env).grafanaService,
      $.parts(params, env).grafanaDeploy,
      $.parts(params, env).grafanaServiceAccount,
      $.parts(params, env).grafanaProvidersConfigMap,
      $.parts(params, env).grafanaDashboardsConfigMap,
    ],

  backfilljob(params, env)::
    [$.parts(params, env).backFillJob],

  syncCronJob(params, env)::
    [$.parts(params, env).syncCronJob],

  parts(params, env):: {
    local namespace = env.namespace,

    local devstatsImage = "gcr.io/kubeflow-ci/devstats:latest",
    local devStatsDbName = "devstatsdb",

    // Where to mount the projects config map
    local projectsMountPoint = "/etc/projects-volume",

    // Environment variables to be set on various pods.
    // These control the devstats tools
    local devstatsEnv = [
      {
        name: "PG_HOST",
        value: devStatsDbName + "-0." + devStatsDbName + "." + namespace + ".svc.cluster.local",
      },
      {
        name: "PG_DB",
        value: "gha",
      },
      {
        name: "PG_PASS",
        value: "password",
      },
      {
        name: "IDB_PASS",
        value: "password",
      },
      {
        name: "IDB_DB",
        value: "kubeflow",
      },
      {
        // TODO(jlewi): Is this supposed to match the name in projects.yaml?
        name: "GHA2DB_PROJECT",
        value: "kubeflow",
      },
      {
        name: "IDB_PASS_RO",
        value: "password_ro",
      },
      {
        name: "IDB_HOST",
        value: "influxdb-set-0.influxdb.devstats.svc.cluster.local",
      },
      {
        // Used by some of the devstats scripts to affect which dbs we modify.
        name: "ONLY",
        value: "devstats gha",
      },
      {
        name: "GHA2DB_GITHUB_OAUTH",
        valueFrom: {
          secretKeyRef: {
            name: "github-oauth",
            key: "github-oauth",
          },
        },
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
                    {
                      name: "POSTGRES_USER",
                      value: "gha_admin",
                    },
                    {
                      name: "POSTGRES_PASSWORD",
                      value: "password",
                    },
                    {
                      // This is the default DB; it is created on container startup if it doesn't
                      // exist.
                      name: "POSTGRES_DB",
                      value: "gha",
                    },
                    {
                      name: "PGDATA",
                      value: "/var/lib/postgresql/data/ghadb-postgre",
                    },
                  ] + devstatsEnv,
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
                  volumeMounts: [
                    {
                      mountPath: "/var/lib/postgresql/data",
                      name: "db",
                    },
                  ],
                },  // Postgres container
                // A CLI container that runs as root.
                // This is for manual modification of the PD.
                {
                  command: [
                    "tail",
                    "-f",
                    "/dev/null",
                  ],
                  env: devstatsEnv,
                  image: devstatsImage,
                  name: "cli",
                  volumeMounts: [
                    {
                      mountPath: "/var/lib/postgresql/data",
                      name: "db",
                    },
                  ],
                },  // cli
              ],  // containers
              volumes: [
                {
                  gcePersistentDisk: {
                    fsType: "ext4",
                    pdName: diskName,
                  },
                  name: "db",
                },
              ],
            },
          },
        },
      },  //stateful set
    ],  // postgreDb

    // Create a pod running as a stateful set that we can use
    // to execute commands manually.
    //
    // TODO(jlewi): We could probably get rid of this now that we run it in a sidecar.
    cli:: {
      apiVersion: "apps/v1",
      kind: "StatefulSet",
      metadata: {
        name: "devstats-cli",
        namespace: namespace,
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
                volumeMounts: [
                  {
                    mountPath: projectsMountPoint,
                    name: "projects-volume",
                  },
                ],
              },
            ],
            terminationGracePeriodSeconds: 10,
            volumes: [
              {
                configMap: {
                  name: "projects",
                },
                name: "projects-volume",
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
                volumeMounts: [
                  {
                    mountPath: projectsMountPoint,
                    name: "projects-volume",
                  },
                ],
              },
            ],
            restartPolicy: "OnFailure",
            terminationGracePeriodSeconds: 10,
            volumes: [
              {
                configMap: {
                  name: "projects",
                },
                name: "projects-volume",
              },
            ],
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
                    volumeMounts: [
                      {
                        mountPath: projectsMountPoint,
                        name: "projects-volume",
                      },
                    ],
                  },
                ],
                restartPolicy: "OnFailure",
                terminationGracePeriodSeconds: 10,
                volumes: [
                  {
                    configMap: {
                      name: "projects",
                    },
                    name: "projects-volume",
                  },
                ],
              },
            },
          },
        },  // template
      },
    },  // syncCronJob

    influxdbService:: {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        labels: {
          app: "influx",
        },
        name: "influxdb",
        namespace: namespace,
      },
      spec: {
        clusterIP: "None",
        ports: [
          {
            name: "http",
            port: 8086,
          },
          {
            name: "administrator",
            port: 8083,
          },
          {
            name: "graphite",
            port: 2003,
          },
        ],
        selector: {
          app: "influx",
        },
      },
    },

    influxdbStatefulSet:: {
      apiVersion: "apps/v1",
      kind: "StatefulSet",
      metadata: {
        name: "influxdb-set",
        namespace: namespace,
      },
      spec: {
        replicas: 1,
        selector: {
          matchLabels: {
            app: "influx",
          },
        },
        serviceName: "influxdb",
        template: {
          metadata: {
            labels: {
              app: "influx",
            },
          },
          spec: {
            containers: [
              {
                image: "influxdb:1.5.2",
                name: "influx",
                ports: [
                  {
                    containerPort: 8086,
                  },
                  {
                    containerPort: 8083,
                  },
                  {
                    containerPort: 2003,
                  },
                ],
                volumeMounts: [
                  {
                    mountPath: "/var/lib/influxdb",
                    name: "influxdb",
                  },
                ],
              },
            ],
            volumes: [
              {
                gcePersistentDisk: {
                  fsType: "ext4",
                  pdName: "influxdb-data",
                },
                name: "influxdb",
              },
            ],
          },
        },
      },
    },  // influxdbserviceStatefulSet

    projectsConfigMap:: {
      apiVersion: "v1",
      kind: "ConfigMap",
      metadata: {
        name: "projects",
        namespace: namespace,
      },

      data: {
        "projects.yaml": importstr "projects.yaml",
      },
    },

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
      },
    },

    grafanaProvidersConfigMap:: {
      apiVersion: "v1",
      kind: "ConfigMap",
      metadata: {
        name: "grafana-providers",
        namespace: namespace,
      },

      data: {
        "providers_config.yaml": importstr "grafana/providers.yaml",
      },
    },

    // This config map provides all the dashboards.
    grafanaDashboardsConfigMap:: {
      apiVersion: "v1",
      kind: "ConfigMap",
      metadata: {
        name: "grafana-dashboards",
        namespace: namespace,
      },

      // You can use the script print_imports.sh to generate text that
      // can be copy pasted here.      
      data: {
"activity-repository-groups.json": importstr "grafana/dashboards/activity-repository-groups.json",
"approvers-in-repository-groups-table.json": importstr "grafana/dashboards/approvers-in-repository-groups-table.json",
"approvers-repository-groups.json": importstr "grafana/dashboards/approvers-repository-groups.json",
"blocked-prs-repository-groups.json": importstr "grafana/dashboards/blocked-prs-repository-groups.json",
"bot-commands-repository-groups.json": importstr "grafana/dashboards/bot-commands-repository-groups.json",
"commenters-in-repository-groups.json": importstr "grafana/dashboards/commenters-in-repository-groups.json",
"comments-in-repository-groups.json": importstr "grafana/dashboards/comments-in-repository-groups.json",
"commits-repository-groups.json": importstr "grafana/dashboards/commits-repository-groups.json",
"community-stats-repositories.json": importstr "grafana/dashboards/community-stats-repositories.json",
"companies-contributing-in-repository-groups.json": importstr "grafana/dashboards/companies-contributing-in-repository-groups.json",
"companies-statistics-repository-groups.json": importstr "grafana/dashboards/companies-statistics-repository-groups.json",
"companies-table.json": importstr "grafana/dashboards/companies-table.json",
"companies-velocity-repository-groups.json": importstr "grafana/dashboards/companies-velocity-repository-groups.json",
"dashboards.json": importstr "grafana/dashboards/dashboards.json",
"developers-table.json": importstr "grafana/dashboards/developers-table.json",
"first-non-author-activity-repository-groups.json": importstr "grafana/dashboards/first-non-author-activity-repository-groups.json",
"issues-repository-group.json": importstr "grafana/dashboards/issues-repository-group.json",
"new-and-episodic-contributors-repository-groups.json": importstr "grafana/dashboards/new-and-episodic-contributors-repository-groups.json",
"new-and-episodic-issues-repository-groups.json": importstr "grafana/dashboards/new-and-episodic-issues-repository-groups.json",
"new-prs-repository-groups.json": importstr "grafana/dashboards/new-prs-repository-groups.json",
"opened-to-merged-repository-groups.json": importstr "grafana/dashboards/opened-to-merged-repository-groups.json",
"open-issues-prs-by-milestone-and-repository.json": importstr "grafana/dashboards/open-issues-prs-by-milestone-and-repository.json",
"pr-comments.json": importstr "grafana/dashboards/pr-comments.json",
"project-statistics-table.json": importstr "grafana/dashboards/project-statistics-table.json",
"prs-age-repository-groups.json": importstr "grafana/dashboards/prs-age-repository-groups.json",
"prs-approval-repository-groups.json": importstr "grafana/dashboards/prs-approval-repository-groups.json",
"prs-approval-repository-groups-stacked.json": importstr "grafana/dashboards/prs-approval-repository-groups-stacked.json",
"prs-authors-companies-table.json": importstr "grafana/dashboards/prs-authors-companies-table.json",
"prs-authors-repository-groups.json": importstr "grafana/dashboards/prs-authors-repository-groups.json",
"prs-authors-repository-groups-table.json": importstr "grafana/dashboards/prs-authors-repository-groups-table.json",
"prs-labels-repository-groups.json": importstr "grafana/dashboards/prs-labels-repository-groups.json",
"prs-merged-repository-groups.json": importstr "grafana/dashboards/prs-merged-repository-groups.json",
"prs-merged-repos.json": importstr "grafana/dashboards/prs-merged-repos.json",
"reviewers-in-repository-groups-table.json": importstr "grafana/dashboards/reviewers-in-repository-groups-table.json",
"reviewers-repository-groups.json": importstr "grafana/dashboards/reviewers-repository-groups.json",
"suggested-approvers-repository-groups.json": importstr "grafana/dashboards/suggested-approvers-repository-groups.json",
"time-metrics-by-repository-groups.json": importstr "grafana/dashboards/time-metrics-by-repository-groups.json",
"top-commenters-in-repository-groups-table.json": importstr "grafana/dashboards/top-commenters-in-repository-groups-table.json",
"user-reviews-repository-groups.json": importstr "grafana/dashboards/user-reviews-repository-groups.json",
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
                    value: "/data/grafana",
                  },

                  // Override the location used for provisioning so we
                  // can provide the sources via a configmap.
                  // See http://docs.grafana.org/administration/provisioning/#dashboards
                  {
                    name: "GF_PATHS_PROVISIONING",
                    value: "/conf/grafana/provisioning",
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
                volumeMounts: [
                  {
                    mountPath: "/data/grafana",
                    name: "grafana-data",
                  },
                  {
                    mountPath: "/conf/grafana/provisioning/dashboards",
                    name: "grafana-providers",
                  },

                  {
                    mountPath: "/conf/grafana/dashboards",
                    name: "grafana-dashboards",
                  },
                ],
              },
            ],
            volumes: [
              {
                // We use a PD because we want the data to be preserved. Futhermore, even if the app is taken down
                // we don't want the data to be lost so we don't use dynamic PV.
                gcePersistentDisk: {
                  fsType: "ext4",
                  pdName: "grafana-data",
                },
                name: "grafana-data",
              },              
              {
                configMap: {
                  name: "grafana-dashboards",
                },
                name: "grafana-dashboards",
              },
{             configMap: {
                  name: "grafana-providers",
                },
                name: "grafana-providers",
              },   
            ],
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
