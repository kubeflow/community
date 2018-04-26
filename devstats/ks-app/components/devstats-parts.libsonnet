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

  },  // parts
}
