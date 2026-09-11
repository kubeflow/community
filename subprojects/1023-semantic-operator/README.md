# Application Form: Semantic Operator

**Related GitHub issue:** https://github.com/kubeflow/community/issues/1023

**Public proposal document:** https://docs.google.com/document/d/1jdVXhQMKyksz0deS36obgrw02aEnvHgZcd2W6ds3FDE/edit

## CNCF Short Checklist

- [x] All project metadata and resources are vendor-neutral
- [ ] Governance structure
- [ ] Contributing guides
- [ ] Public list of adopters

The unchecked items are part of the proposed transition plan. They are not represented as complete today.

## Background Information

### Submitter Name

- Vara Bonthu ([@vara-bonthu](https://github.com/vara-bonthu))
- Manabu McCloskey ([@nabuskey](https://github.com/nabuskey))

### Submitter's relationship to project / title

- Vara Bonthu, co-creator and maintainer of Semantic Operator and Principal Open Source Architect at AWS
- Manabu McCloskey, co-creator and maintainer of Semantic Operator and Senior Open Source Engineer at AWS

Both submitters also maintain the Kubeflow Spark Operator and Spark History Server MCP projects.

### Project Name

**Semantic Operator**

### Why is this project valuable to the Kubeflow Community?

AI agents can generate SQL that runs successfully and still returns the wrong business answer. The agent may select the wrong column, apply the wrong aggregation, follow an unsafe join path, or ignore access policy. These failures are difficult to detect because the output often looks plausible.

Semantic Operator gives agents, applications, and BI tools a governed semantic interface to analytical data. Teams define certified metrics, dimensions, relationships, and policies once in an [Apache Ossie](https://ossie.apache.org/) `SemanticModel` Kubernetes custom resource. A deterministic planner converts each valid semantic request into exactly one SQL statement for the configured query engine. The language model selects certified business concepts. It does not generate SQL.

This project would add a missing data-to-agent layer to Kubeflow. Kubeflow helps teams build and operate models and agents. Semantic Operator would help those systems retrieve consistent, governed business facts from enterprise data platforms.

### Why is it beneficial for this project to be a part of the Kubeflow Community?

Semantic infrastructure should not be controlled by one vendor. Kubeflow can provide neutral governance, a recognizable home for contributors, and integration with the broader cloud-native AI ecosystem. Donation would also make the project public and establish community processes for ownership, releases, security response, roadmap decisions, and long-term maintenance.

The project follows the same general operational model as other Kubeflow operators. Kubernetes custom resources declare desired state, a controller validates and publishes that state, and a separately scalable service consumes it. This makes Kubeflow a natural community for the project.

### List of existing and potential integrations with Kubeflow Core components


- **Kubeflow Pipelines**: Pipelines can validate and publish semantic models, or query certified metrics as pipeline inputs and evaluation outputs.
- **Kubeflow Model Registry**: Model metadata can reference the semantic model version and governed metrics used to train, evaluate, or monitor a model.
- **Kubeflow Trainer**: Training jobs can consume reproducible, governed analytical definitions instead of embedding business logic in individual jobs.
- **Kubeflow Notebooks**: Data scientists can discover and query certified metrics without copying SQL or metric definitions into notebooks.
- **Kubeflow Spark Operator**: Spark jobs can prepare physical datasets that Semantic Operator binds to certified semantic models. The projects remain independently deployable.

### Short Description / Functionality

Semantic Operator is a Kubernetes operator and stateless semantic server written in Go. It runs an Apache Ossie semantic layer on an existing StarRocks or Trino query engine.

Its principal capabilities are:

- An Apache Ossie-based `SemanticModel` custom resource for datasets, fields, relationships, metrics, and AI context
- Structural validation and bounded expression grammars
- Live schema binding and drift detection before publication
- Deterministic compilation into a versioned artifact
- A deterministic planner that emits one governed SQL statement per request
- Compile-time row, column, and metric authorization
- MCP, REST, and governed SQL-view interfaces
- StarRocks and Trino dialects and query clients
- Catalog-derived model scaffolding from JDBC-compatible information schemas and AWS Glue, with DataHub enrichment
- Optional Valkey plan and result caching
- Prometheus metrics, structured logs, and optional OpenTelemetry tracing
- A Helm chart with namespace-scoped RBAC, NetworkPolicy, availability controls, and ClusterIP-only service exposure

### Adoption

The project is in an early community-building stage. It includes runnable StarRocks and Trino examples and a benchmark comparing governed semantic queries with direct text-to-SQL. A public adopter list has not yet been established. Creating `ADOPTERS.md` and inviting verifiable adopter entries are explicit transition tasks.

### License Agreement

Apache License 2.0.

### Part of an Open Source Foundation?

No. Semantic Operator is currently an independent project proposed for donation to Kubeflow. It implements the [Apache Ossie](https://ossie.apache.org/) incubating semantic model specification, but it is not itself an Apache Software Foundation project.

### Vendor Neutrality

The core architecture is vendor-neutral. Query engines implement a dialect and database-client interface. Catalog sources and metadata enrichers use separate extension interfaces. StarRocks and Trino are implemented today. The design does not require a specific cloud provider, model provider, catalog, object store, or Kubernetes distribution.

AWS Glue is one optional catalog source. DataHub and engine information schemas are also supported. Additional engines and catalogs can be added without changing the semantic model or serving interfaces.

### Trademark transition

The maintainers are prepared to transfer the repository and any project-owned branding or domains that are eligible for transfer. The name and trademark position should be reviewed with the Kubeflow Steering Committee and Linux Foundation counsel as part of acceptance. Apache Ossie remains a trademark and project of the Apache Software Foundation and is referenced only to describe compatibility.

### CI/CD Infra Requirements

The project currently uses GitHub Actions to:

- Run Go formatting, linting, vetting, and tests
- Verify generated Kubernetes code and CRDs are current
- Lint and render the Helm chart
- Build both container-image targets
- Enforce security guardrails, including preventing public Kubernetes Service types
- Build and publish the documentation site

Following acceptance, workflows, image publication, release signing, dependency updates, and security scanning would be aligned with Kubeflow infrastructure and policies.

### Governance Structure

The project is currently maintained by Vara Bonthu and Manabu McCloskey. It does not yet have a standalone governance document or `OWNERS` file. As part of the transition, the maintainers propose to adopt Kubeflow's OWNERS-based governance, review requirements, contributor ladder, and Steering Committee oversight. Additional maintainers would be added through demonstrated sustained contribution.

### Website

https://kubedai.github.io/semantic-operator

The project already includes a dedicated documentation website built with Astro and Starlight and published through GitHub Pages. It covers architecture, installation, security, development, extension interfaces, and runnable examples. After acceptance, the site will move to Kubeflow-managed hosting and branding, with redirects from the existing location where possible.

### GitHub repository

https://github.com/KubedAI/semantic-operator (Private repo)

The repository is proposed for transfer to `kubeflow/semantic-operator` after approval.

### 1st Release date

No tagged public release has been published yet. The Helm chart currently identifies the application as version `0.1.0`. The first community release would be planned with the responsible Kubeflow Working Group after the repository transition.

### Project Meeting Times

No separate recurring project meeting exists today. The maintainers propose initially using the responsible Kubeflow Working Group and Community Call, then adding a dedicated public meeting only if contributor activity requires it.

### Meeting Notes

Meeting notes will use Kubeflow community infrastructure after the project is accepted. Proposal discussion and decisions will remain public through the Kubeflow community issue, pull request, meeting notes, and recordings.

### Installation Documentation

The project provides a Helm-based quickstart and runnable examples for StarRocks and Trino. The chart requires an existing reachable query engine and deploys the operator and server as namespace-scoped Kubernetes workloads.

Documentation: https://kubedai.github.io/semantic-operator/start/quickstart

### Project Documentation

Documentation covers architecture, access and credentials, semantic model authoring, development, extension interfaces, and runnable examples.

Documentation: https://kubedai.github.io/semantic-operator

### Proposed Maturity

Semantic Operator proposes entering Kubeflow at the Experimental maturity level. The project is functional but does not yet have a public release, public adopter list, or broad community ownership. Progression will follow [Kubeflow's published subproject maturity requirements](../maturity_requirements.md).

### Security Profile

The project has several implemented security controls:

- Separate least-privilege engine credentials for the manager and query server
- Namespace-scoped RBAC by default, with cluster-wide watch as an explicit option
- JWT authentication through issuer JWKS validation
- Trusted-header authentication only when explicitly acknowledged and placed behind an authenticating proxy
- Compile-time row, column, and metric authorization before SQL generation
- Bounded grammars for metric expressions and governance predicates
- Distroless, non-root container images with CGO disabled
- Kubernetes NetworkPolicy templates
- ClusterIP-only service exposure enforced by chart validation and CI
- Read-only server database access and narrowly scoped manager metadata and view-DDL access

The project does not yet have a standalone `SECURITY.md`, a published vulnerability-reporting process, release signing, or a documented CVE response policy. These are required transition tasks. NetworkPolicy enforcement depends on the cluster CNI and is documented as such.

### Ownership / Legal Profile

The source is licensed under Apache License 2.0. The current Git history contains contributions from the two maintainers. Before transfer, the maintainers will complete a provenance and dependency-license review, confirm employer authorization where required, adopt the Developer Certificate of Origin process, and resolve any branding or domain transfer requirements identified by Kubeflow or Linux Foundation counsel.

### Authorization, Isolation mechanisms

- Kubernetes access is namespace-scoped by default.
- The server can validate JWTs and derive semantic roles and claims from verified identities.
- Governance policies restrict metrics, columns, and rows before query planning.
- Manager and server database identities are separated by responsibility.
- Compiled models are versioned and published only after validation and physical-schema drift checks succeed.
- The last successfully published model remains available when a new model fails validation or drift checking.

Multi-tenant serving across namespaces and richer attribute-based policies that require external lookups are not implemented today. These are roadmap items and will not be implied by the initial donation.

### Project Roadmap

#### Donation readiness

- Make the repository and issue tracker public
- Add `OWNERS`, `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `RELEASE.md`, and `ADOPTERS.md`
- Complete provenance, dependency-license, trademark, and employer-authorization reviews
- Adopt DCO checks and Kubeflow issue and pull request templates
- Define a security response and release process
- Establish baseline project and adoption metrics

#### Kubeflow integration

- Transfer the repository to the Kubeflow GitHub organization after approval
- Move image publication and documentation to community-managed infrastructure
- Align installation patterns with Kubeflow manifests and supported distributions
- Work with Kubeflow Community Distribution maintainers on optional inclusion after the project has a supported Kubeflow release, manifests, and integration tests
- Define integration examples for Kubeflow Pipelines, KServe, Model Registry, Trainer, Notebooks, and Profiles
- Add conformance and upgrade tests across supported Kubernetes versions

#### Technical roadmap

- Expand query-engine support through the existing dialect and client interfaces
- Expand catalog-source and business-metadata enrichment integrations
- Improve multi-namespace and multi-team isolation
- Add pluggable workload identity and short-lived database credential providers
- Add scalable compiled-artifact storage beyond the Kubernetes ConfigMap size boundary
- Improve policy expressiveness while preserving deterministic planning and compile-time enforcement
- Track [Apache Ossie](https://ossie.apache.org/) evolution and maintain explicit compatibility documentation
- Publish a compatibility matrix covering supported Apache Ossie specification versions, expression dialects, and executable query engines

### Other Information

Semantic Operator is different from an LLM text-to-SQL gateway. The LLM is not trusted to construct joins, aggregations, policies, or SQL. It can select from certified semantic concepts exposed through MCP. The server validates that request and creates deterministic SQL from a versioned model.

The proposal also does not ask Kubeflow to own Apache Ossie. Semantic Operator is an independent Kubernetes implementation that consumes the Apache Ossie specification and adds Kubernetes lifecycle, schema drift checking, governance, serving protocols, and query-engine integrations.

The maintainers intend to collaborate with the Apache Ossie community, contribute implementation feedback, and reduce avoidable compatibility breaks as the specification evolves. Semantic Operator aims to serve as a Kubernetes reference implementation of the specification, subject to alignment with the Apache Ossie community. Kubernetes-specific extensions will remain separate from the portable Ossie document.

## Metrics

- **Number of Maintainers and their Affiliations**: 2. Vara Bonthu and Manabu McCloskey. Affiliations will be recorded in the initial `OWNERS` and governance documents.
- **Number of Releases in the last 12 months**: 0 tagged releases
- **Number of Contributors**: 2 contributors in the current Git history
- **Number of Users**: Not yet measured
- **Number of Forks**: Not yet available as a public project metric
- **Number of Stars**: Not yet available as a public project metric
- **Number of package/project installations/downloads**: Not yet measured

These values should be refreshed immediately before the proposal pull request is opened.

## Kubeflow Checklist

1. Overlap with existing Kubeflow projects
   - [] Yes
   - [x] No

   The project complements Kubeflow Pipelines, KServe, Model Registry, Trainer, Notebooks, Profiles, and Spark Operator. It does not duplicate their lifecycle responsibilities. No existing Kubeflow component provides an Apache Ossie-compatible, deterministic, governed semantic query layer.

1. Manifest Integration
   - [ ] Yes
   - [ ] No
   - [x] Planned

1. Commitment to Kubeflow Conformance Program
   - [x] Yes
   - [ ] No
   - [ ] Uncertain

1. Installation
   - [x] Standalone/Self-contained Component
   - [ ] Part of Manifests
   - [ ] Part of Distributions

1. Installation Documentation (Current Quality)
   - [x] Good
   - [ ] Fair
   - [ ] Part of Kubeflow

1. CI/CD
   - [x] Yes
   - [ ] No

1. Release Process
   - [ ] Automated
   - [ ] Semi-automated
   - [x] Not Automated

1. Kubeflow Website Documentation
   - [ ] Yes
   - [x] No

A dedicated documentation website exists today on GitHub Pages. Moving it to Kubeflow-managed hosting and branding is part of the proposed transition.

1. Blog/Social Media
   - [] Yes
   - [x] No

We will write a blog once the repo is moved to Kubeflow

## Proposed Working Group

The maintainers propose the Kubeflow Agents Working Group as the initial home because governed semantic access through MCP is a core capability for AI agents. The `wg-agents` charter and Working Group registration are currently proposed in [PR #1025](https://github.com/kubeflow/community/pull/1025). Subject to approval of that proposal and confirmation by the Working Group leads and Steering Committee, Semantic Operator will collaborate through the Agents Working Group while continuing to work with the Data Working Group and Spark Operator maintainers on analytical-data and processing integrations.

## Proposed Transfer Plan

1. Complete community review and Steering Committee approval.
2. Finish the donation-readiness documents and legal review.
3. Transfer `KubedAI/semantic-operator` to `kubeflow/semantic-operator`.
4. Preserve Git history, issues, and redirects where supported by GitHub.
5. Configure Kubeflow teams, branch protection, DCO, CI, image publishing, and documentation.
6. Publish the first Kubeflow-governed release and migration announcement.
7. Track remaining integration and community-building work in public issues.

## Maintainer Commitment

Vara Bonthu and Manabu McCloskey commit to continue maintaining Semantic Operator during and after the proposed transfer. They will support the governance transition, onboard contributors, respond to security and operational issues, maintain releases, and work toward broader community ownership under Kubeflow governance.
