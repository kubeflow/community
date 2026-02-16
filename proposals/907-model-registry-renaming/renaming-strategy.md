# Technical Renaming Strategy \- Kubeflow Model Registry to Kubeflow Hub

## Status

**Proposed** \- Pending community review and approval

## Context

The Kubeflow community has approved [KEP-907](https://github.com/kubeflow/community/pull/907) to rename "Kubeflow Model Registry" to "Kubeflow Hub". This decision reflects the project's evolution to support two distinct use cases:

1. **Model Registry (Tenant-Scoped)**: Tracks model evolution during development, focusing on per-team model iterations, experiments, training runs, parameters, and metrics.  
     
2. **Model Catalog (Cluster-Scoped)**: Showcases organization-approved models, enables enterprise-wide model sharing, and supports GenAI/LLM model discovery.

The name "Kubeflow Hub" aligns with industry conventions (Docker Hub, Hugging Face Hub) and better represents the project's broader AI/ML asset management capabilities.

**This ADR documents the technical analysis of rename impacts, backwards compatibility considerations, and provides recommendations for each affected area.**

---

## Executive Summary

### Core Architectural Decision

**Kubeflow Hub is an umbrella project name** that groups AI asset management components:

- **Model Registry** (tenant-scoped model evolution tracking)  
- **Model Catalog** (cluster-scoped approved model showcase)  
- **Future capabilities** (datasets, prompts, notebooks, etc.)

**Critical Principle**: Component names (`model-registry`, `catalog`) accurately describe their specific functionality and **remain unchanged** even under the Hub umbrella. This minimizes breaking changes while allowing the project to evolve.

### What's Changing

1. **Repository name**: `kubeflow/model-registry` → `kubeflow/hub`  
2. **Go module paths**: Updated with major version bump  
3. **Container images**: Updated repo name `ghcr.io/kubeflow/model-registry` → `ghcr.io/kubeflow/hub`  
4. **Documentation**: Updated to explain Hub architecture  
5. **Website**: Similar updates as for documentation

### What's NOT Changing (Zero Breaking Changes)

1. **API paths**: `/api/model_registry/v1alpha3/` and `/model_catalog/` remain unchanged  
   - New addition: `/ai_assets_catalog/` alias for catalog  
2. **Python SDK**: Package name stays `model-registry`  
   - ***Note:*** We now have a client kubeflow/sdk under the kubeflow.hub module: `https://github.com/kubeflow/sdk/tree/main/kubeflow/hub`  
3. **Kubernetes resources**: Service names like `model-registry-ui`, `catalog-service` unchanged  
4. **Database names**: No schema changes

### Key Benefit

This approach provides clear project identity (Kubeflow Hub) while maintaining stable, accurate component names that minimize disruption to existing users and integrations.

---

## Decision Drivers

- Minimize disruption to existing users and integrations  
- Maintain backwards compatibility where feasible  
- Provide clear migration paths  
- Balance immediate changes vs. deprecation periods  
- Align with Kubeflow ecosystem practices

---

## Areas of Impact Analysis

### 1\. Repository Name Change

**Current**: `github.com/kubeflow/model-registry` **Proposed**: `github.com/kubeflow/hub`

#### Pros

- Clean break with new identity  
- GitHub automatically redirects old URLs to new repository  
- Fresh namespace for issues, PRs, discussions

#### Cons

- **HIGH IMPACT**: All Go import paths break immediately  
- All existing forks reference old repository  
- All external documentation links need updating  
- Bookmarks and CI/CD configurations across the ecosystem break

#### Backwards Compatibility Impact

| Aspect | Impact Level | Mitigation |
| :---- | :---- | :---- |
| Go imports | **BREAKING** | Requires code changes in all consumers |
| Git clone URLs | Low | GitHub provides automatic redirects |
| Issue/PR links | Low | GitHub provides automatic redirects |
| Release artifacts | Medium | Old tags remain accessible via redirects |

#### Recommendation

**PHASE 1** \- Rename repository with redirect.

---

### 2\. Go Module Path Changes

**Current**: `github.com/kubeflow/model-registry` **Proposed**: `github.com/kubeflow/hub`

#### Affected Files (Primary)

- `/go.mod` (root module)  
- `/pkg/openapi/go.mod`  
- `/catalog/pkg/openapi/go.mod`  
- `/clients/ui/bff/go.mod`  
- `/gorm-gen/go.mod`

#### Affected Imports

**889+ occurrences across 325+ files** require updating.

#### Pros

- Consistent with new project identity  
- Go module versioning can restart cleanly

#### Cons

- **BREAKING CHANGE**: All downstream Go consumers must update imports  
- Requires coordinated release with consumers (kubeflow/manifests, kubeflow/pipelines integrations)  
- Existing `replace` directives in external projects break

#### Backwards Compatibility Impact

| Consumer Type | Impact | Mitigation Strategy |
| :---- | :---- | :---- |
| Direct Go imports | **BREAKING** | Repository redirects |
| `go get` users | **BREAKING** | Document migration path |
| Vendored dependencies | **BREAKING** | Announce in release notes |

#### Recommendation

**DO**: Rename Go module paths as part of a major version bump (e.g., v0.3.0 or v1.0.0). **CONSIDER**: Using Go module `replace` directives temporarily to support both import paths during transition.

---

### 3\. Container Image Names

**Current Registry**: `ghcr.io/kubeflow/model-registry/` **Images**:

- `ghcr.io/kubeflow/model-registry/server`  
- `ghcr.io/kubeflow/model-registry/ui`  
- `ghcr.io/kubeflow/model-registry/ui-standalone`  
- `ghcr.io/kubeflow/model-registry/ui-federated`  
- `ghcr.io/kubeflow/model-registry/storage-initializer`  
- `ghcr.io/kubeflow/model-registry/async-upload`

**Proposed Registry**: `ghcr.io/kubeflow/hub/`

#### Pros

- Consistent with new branding  
- Clear identity in container registries

#### Cons

- **HIGH IMPACT**: All Kubernetes deployments referencing old images break  
- Helm charts, kustomize overlays, and external deployments need updating  
- CI/CD pipelines across the ecosystem need updating

#### Backwards Compatibility Impact

| Aspect | Impact Level | Mitigation |
| :---- | :---- | :---- |
| Existing deployments | **BREAKING** | Image tags won't resolve |
| Kubeflow Manifests | **BREAKING** | Will need update to new images following a release |
| Helm values | **BREAKING** | Requires values.yaml changes |
| Air-gapped environments | **HIGH** | Must re-mirror images |

#### Recommendation

**DO**: Publish images under **NEW** namespace after **transition period announcement**. **DO**: Add deprecation warnings in image labels and documentation. **DO**: Provide clear migration timeline in release notes. **DO NOT**: Remove old images until minimum transition period complete AND after coordination with kubeflow/manifests.

#### Implementation Strategy

```
# CI workflow change - publish to both registries
- name: Push to primary registry (kubeflow-hub)
  run: docker push ghcr.io/kubeflow/hub/server:${{ env.VERSION }}

- name: Push to legacy registry (model-registry) - DEPRECATED
  run: |
    docker push ghcr.io/kubeflow/model-registry/server:${{ env.VERSION }}
    echo "⚠️  WARNING: ghcr.io/kubeflow/model-registry is deprecated"
    echo "   Migrate to: ghcr.io/kubeflow/hub"
    echo "   Support ends: [DATE]"

- name: Add deprecation labels to legacy images
  run: |
    docker tag ghcr.io/kubeflow/model-registry/server:${{ env.VERSION }} \
      --label "org.opencontainers.image.deprecated=true" \
      --label "org.opencontainers.image.migration.target=ghcr.io/kubeflow/hub"
```

#### Consumer Migration Path

```
# Before (legacy registry)
image: ghcr.io/kubeflow/model-registry/server:v0.3.0

# After (new registry)
image: ghcr.io/kubeflow/hub/server:v0.3.0
```

---

### 4\. API Path Changes

**Current Paths**:

- Model Registry: `/api/model_registry/v1alpha3/`  
- Model Catalog: `/model_catalog/` (or similar catalog path)

**Architectural Decision**: Kubeflow Hub is a *conceptual grouping* of AI asset management components. Internal component names ("model-registry", "catalog") remain unchanged as they accurately describe their specific functionality.

#### Model Registry API \- No Changes

**Decision**: **KEEP** `/api/model_registry/v1alpha3/` unchanged.

**Rationale**:

- Zero breaking changes for API consumers  
- Model Registry accurately describes this component's purpose (tracking model evolution)  
- Component name remains valid even under Hub umbrella  
- Python clients, integrations continue working seamlessly

#### Model Catalog API \- Additive Changes Only

**Current**: `/model_catalog/` **Proposed Addition**: `/ai_assets_catalog/` (routes to same handler)

**Decision**: **ADD** `/ai_assets_catalog/` as an alias path alongside existing `/model_catalog/` path.

**Rationale**:

- **Forward compatibility**: Prepares for future expansion beyond just models (datasets, prompts, notebooks, etc.)  
- **Backward compatibility**: Existing `/model_catalog/` continues working  
- **Zero breaking changes**: Additive only, no removals  
- **Future-proof**: When we expand to other AI assets, the path naming already supports it

**Implementation**:

```go
// Both paths route to the same handler
router.Handle("/model_catalog/", catalogHandler)
router.Handle("/ai_assets_catalog/", catalogHandler) // New alias
```

#### Future Considerations

- When Model Registry component evolves, consider adding `/ai_assets_registry/` as similar alias  
- Catalog can be extended to support asset types beyond models without API path changes  
- Component-specific paths (`/model_catalog/`, `/model_registry/`) remain authoritative

#### Recommendation

**DO**: Add `/ai_assets_catalog/` path as alias for catalog functionality **DO**: Keep all existing API paths unchanged **DO NOT**: Rename existing API paths **DOCUMENT**: Clearly explain that both paths are supported and equivalent

---

### 5\. Python Client Package

**Current**:

- PyPI package: `model-registry`  
- Import path: `from model_registry import ModelRegistry`  
- OpenAPI module: `mr_openapi`

**Architectural Decision**: The Python SDK provides programmatic access to the **Model Registry component** specifically. Since "Model Registry" accurately describes this component's functionality (tracking model evolution, versioning, metadata), the package name remains correct even under the Kubeflow Hub umbrella.

#### Decision: Keep Package Name Unchanged

**Rationale**:

- **Component naming accuracy**: "model-registry" correctly describes what this SDK does \- it's the client for the Model Registry component  
- **Zero breaking changes**: All existing code continues working  
- **Kubeflow Hub is a grouping concept**: The Hub groups Model Registry \+ Catalog \+ future AI asset components  
- **SDK scope**: This SDK is specifically for Model Registry operations, not for the entire Hub  
- **Industry precedent**: Docker Hub contains many SDKs that keep component-specific names

#### Backwards Compatibility Impact

| Aspect | Impact Level | Mitigation |
| :---- | :---- | :---- |
| pip install | **NONE** | No changes required |
| Import statements | **NONE** | No changes required |
| Existing notebooks | **NONE** | No changes required |
| Tutorials | **NONE** | No changes required |

#### Future Considerations

- Component-specific SDKs remain more useful than monolithic Hub SDK for most use cases

#### Recommendation

**DO NOT** rename the Python package. Keep `model-registry` on PyPI. **DOCUMENT**: Clearly explain that `model-registry` is the SDK for the Model Registry component within Kubeflow Hub. **DOCUMENT**: Any new “user facing” client shall be developed directly in Kubeflow/SDK.\[**CONSIDER**: Add Kubeflow Hub branding to documentation while keeping functional package name.

---

### 6\. Kubernetes Manifests and CRDs

**Current References**:

- Service names: `model-registry-ui`, `model-registry`, `catalog-service`  
- Deployment names: `model-registry-deployment`, `catalog-deployment`  
- ConfigMaps: `model-registry-*`, `catalog-*`  
- Labels: `app: model-registry-ui`, `app: catalog`  
- RBAC: `model-registry-manager-role`, `catalog-manager-role`

#### Critical Analysis: Should Kubernetes Resources Be Renamed?

**Architectural Question**: If Kubeflow Hub is a *conceptual grouping* of AI asset management components (Model Registry \+ Catalog), and these component names remain valid and descriptive, do the Kubernetes resources need renaming?

**Answer: NO \- Component Names Should Remain Unchanged**

#### Rationale for Keeping Current K8s Resource Names

1. **Kubeflow Hub is organizational, not operational**  
     
   - "Hub" is the project/repository name and umbrella concept  
   - Actual deployed components are "Model Registry" and "Catalog"  
   - K8s resources should reflect deployed component functionality, not project branding

   

2. **Component names are accurate and specific**  
     
   - `model-registry-ui` accurately describes what this service does  
   - `catalog-service` accurately describes what this service does  
   - These names remain correct under the Hub umbrella

   

3. **Industry precedent**  
     
   - Docker Hub doesn't name its services `hub-*`  
   - Artifact repositories don't rename component services to match umbrella branding  
   - Component-level naming is standard practice

   

4. **Zero breaking changes**  
     
   - Service DNS names remain stable (`model-registry.kubeflow.svc.cluster.local`)  
   - Label selectors don't break  
   - RBAC bindings continue working  
   - External integrations (KServe, Pipelines) don't break

   

5. **Separation of concerns**  
     
   - Repository name (`kubeflow/hub`) \= where code lives  
   - Component names (`model-registry`, `catalog`) \= what gets deployed  
   - These don't need to match

#### Backwards Compatibility Impact

| Aspect | Impact Level | Mitigation |
| :---- | :---- | :---- |
| Service DNS names | **NONE** | No changes |
| Label selectors | **NONE** | No changes |
| RBAC bindings | **NONE** | No changes |
| kubeflow/manifests sync | **LOW** | Update comments/documentation only |

#### Optional: Add Hub Context Labels

**Consider** adding metadata labels for organizational clarity WITHOUT changing functional names:

```
apiVersion: v1
kind: Service
metadata:
  name: model-registry-ui  # Functional name - unchanged
  labels:
    app: model-registry-ui
    app.kubernetes.io/part-of: kubeflow-hub  # NEW: Organizational context
    app.kubernetes.io/component: ui
    app.kubernetes.io/name: model-registry
```

This provides:

- Clear organizational grouping for Hub components  
- Standard K8s labels for tooling integration  
- Zero breaking changes to existing selectors  
- Better observability and management

#### Recommendation

**DO NOT** rename Kubernetes service names, deployments, or CRDs **DO** add `app.kubernetes.io/part-of: kubeflow-hub` labels for organizational context **DO** update documentation to explain component naming under Hub umbrella **DO NOT** break existing service DNS names or label selectors

#### Files Requiring Updates

- Documentation comments in manifest files  
- README files explaining the deployment  
- **NO** functional resource name changes needed

---

### 7\. Documentation Updates

#### Documentation Strategy: Emphasize Architectural Clarity

**Key Message**: Kubeflow Hub is an **umbrella project** grouping AI asset management components (Model Registry, Catalog, and future capabilities). Component names remain unchanged as they accurately describe specific functionality.

#### Internal Documentation (This Repository)

| File/Path | Update Type | Key Changes |
| :---- | :---- | :---- |
| `README.md` | **MAJOR** | \- Introduce "Kubeflow Hub" as project name \- Explain Hub as grouping of Model Registry \+ Catalog \- Clarify component names remain unchanged \- Update repository URLs |
| `CONTRIBUTING.md` | **MINOR** | \- Update repository URL references \- Keep component-specific contribution guides |
| `RELEASE.md` | **MODERATE** | \- Update container registry publishing naming \- Note image naming in both registries \- Keep component-specific release notes |
| `docs/*.md` | **MODERATE** | \- Add "Kubeflow Hub" context to introductions \- Maintain component-specific documentation \- Clarify Model Registry vs. Catalog distinction |
| `clients/python/README.md` | **MINOR** | \- Add note: "Python SDK for Model Registry component within Kubeflow Hub" \- Keep all functional documentation unchanged |
| `CLAUDE.md` | **MINOR** | \- Update repository references \- Note: component names unchanged |
| `manifests/*/README.md` | **MODERATE** | \- Explain K8s resource naming strategy \- Document \`app.kubernetes.io/part-of: kubeflow-hub\` labels \- Clarify why service names remain unchanged |

#### External Documentation

| Location | Owner | Action Required |
| :---- | :---- | :---- |
| kubeflow.org | kubeflow/website | update icon by raising CNCF ticket (Matteo can do it) update landing page in the root website page |
| [kubeflow.org/docs](https://www.kubeflow.org/docs/components/model-registry/) | kubeflow/website | \- Update page title to "Kubeflow Hub" \- Add redirect from \`/model-registry/\` to \`/hub/\` or \`/kubeflow-hub/\` \- Document Model Registry and Catalog as Hub components \- Maintain separate guides for each component |
| Community Blog Posts | Community | \- Publish announcement post explaining rename \- Clarify what's changing vs. unchanged \- Historical posts remain as-is (searchable) |
| YouTube Tutorials | Community | \- Add pinned comment for new videos explaining rename for a sensible period \- Link to migration guide \- Add entry line in biweekly meeting notes \- Videos remain valid (component functionality unchanged) |

#### New Documentation Required

1. **Migration Guide** (`docs/migration-to-kubeflow-hub.md`)  
     
   - Repository URL changes  
   - What's NOT changing (critical section)  
   - Timeline and support calendar

   

2. **Architecture Overview** (`docs/architecture/kubeflow-hub-components.md`)  
     
   - Explain Hub as umbrella concept  
   - Detail Model Registry component  
   - Detail Catalog component  
   - Explain why component names remain unchanged  
   - Future expansion areas (datasets, prompts, etc.)

   

3. **FAQ Document** (`docs/faq-kubeflow-hub-rename.md`)  
     
   - "Why keep 'model-registry' in API paths?"  
   - "Why keep 'model-registry' Python package?"  
   - "Why keep K8s service names unchanged?"  
   - "What is Kubeflow Hub vs. Model Registry?"

#### Recommendation

**DO**: Create comprehensive "What's Changing vs. What's Not" documentation **DO**: Emphasize that functional component names remain valid and unchanged **DO**: Coordinate with kubeflow/website for same-day documentation update **DO**: Update component/project icon and update [kubeflow.org](http://kubeflow.org) landing page accordingly **DO**: Add "Kubeflow Hub" branding while maintaining component-specific docs **DO**: Create migration guide even though breaking changes are minimized **DOCUMENT**: Clearly explain architectural decision to keep component names

---

### 8\. CI/CD Pipeline Changes

#### GitHub Actions Workflows Affected

| Workflow | Changes Required |
| :---- | :---- |
| `build-and-push-image.yml` | Update IMG\_REPO, image tags |
| `build-and-push-ui-images.yml` | Update image names |
| `build-and-push-csi-image.yml` | Update image names |
| `trivy-image-scanning.yaml` | Update image references |
| All workflows | Repository name in URLs |

#### Container Registry Configuration

- GitHub Packages namespace change  
- GHCR permissions and tokens  
- Signing keys for images

#### Recommendation

**DO**: Update all workflows in the rename PR. **DO**: Test thoroughly in a fork before merge. **DO**: Maintain ability to push to both old and new registries during transition.

---

### 9\. Database and Schema Considerations

**Current Database Names**:

- `model_registry` (MySQL)  
- `model_catalog` (PostgreSQL)

**Table Names**: Internal to database, not exposed externally.

#### Recommendation

**DO NOT** rename database or table names. This provides:

- Zero impact on existing deployments  
- No migration scripts needed for data  
- Seamless upgrade path

Database names are internal implementation details and need not match the project name.

---

### 10\. Configuration Files and Environment Variables

**Current Patterns**:

- Config file: `.model-registry.yaml`  
- Environment prefix: `MODEL_REGISTRY_*`

#### Backwards Compatibility Impact

| Item | Impact | Recommendation |
| :---- | :---- | :---- |
| Config file name | Medium | Support both old and new names |
| Env variables | Medium | Support both with deprecation warnings |

#### Recommendation

**DO**: Support both `.model-registry.yaml` and `.kubeflow-hub.yaml` config files. **DO**: Log deprecation warning when old config file is detected. **DO**: Support both `MODEL_REGISTRY_*` and `KF_HUB_*` environment variables.

---

## Additional Areas Not Previously Covered

### 11\. Helm Charts (If Applicable)

**Current State**: Project uses Kustomize, not Helm.

**Future Consideration**: If Helm charts are created, use new naming from start.

### 12\. Metrics and Observability

**Current Prometheus Metrics**: May include `model_registry_*` prefixes.

**Recommendation**: Audit metrics endpoints for naming. Consider:

- Keeping old metric names for dashboard compatibility  
- Adding new metric names with old as aliases  
- Documenting metric name changes for monitoring teams

### 13\. Logging and Tracing

**Log Prefixes**: `[model-registry]` or similar.

**Recommendation**: Update log prefixes but note this may affect log parsing rules in production environments.

### 14\. Integration Points

#### KServe Integration

- InferenceService annotations  
- Custom Storage Initializer naming  
- Controller CRD references

#### Kubeflow Pipelines Integration

- Component references  
- SDK imports

**Recommendation**: Coordinate with KServe and Pipelines teams for synchronized updates.

### 15\. Security Considerations

#### Image Signing

- New images need new signatures  
- Cosign/Sigstore configuration updates

#### SBOM (Software Bill of Materials)

- Security scanning references

#### Vulnerability Databases

- CVE references may use old project name

**Recommendation**: Document security artifact migration in release notes.

---

## Phased Migration Plan

### Phase 1: Preparation (Weeks 1-4)

- [ ] Announce rename timeline to community  
- [ ] Create migration documentation emphasizing what's NOT changing  
- [ ] Update CI/CD to support updated container publishing  
- [ ] Coordinate with downstream projects (KServe, Pipelines)  
- [ ] Create FAQ document explaining Hub vs. component names

### Phase 2: Repository Rename (Week 5-6)

- [ ] Rename GitHub repository to `kubeflow/hub` (auto-redirects active)  
- [ ] Update Go module paths with major version bump  
- [ ] Begin publishing containers to new registry name  
- [ ] Update internal documentation  
- [ ] Add `/ai_assets_catalog/` alias path to catalog component

### Phase 3: Community Communication (Weeks 7-8)

- [ ] Update kubeflow.org documentation  
      - raise CNCF ticket for logo update  
      - update landing page  
      - update docs/ in website  
- [ ] Sync kubeflow/manifests (documentation updates only)  
- [ ] Community announcement and blog post  
- [ ] Publish "What's Changing vs. What's Not" guide

### Phase 4: Active Support (Months 2-6)

- [ ] Monitor container registry usage (old vs. new)  
- [ ] Support users during transition  
- [ ] Optionally add `app.kubernetes.io/part-of: kubeflow-hub` labels to manifests  
- [ ] Track feedback on naming decisions

### Phase 5: Evaluation and Sunset (Month 6+)

- [ ] Evaluate legacy container registry usage metrics  
- [ ] If usage is low, announce deprecation of legacy registry  
- [ ] Stop publishing to old container registry after community agreement  
- [ ] Final documentation cleanup

---

## Summary Matrix

| Area | Rename? | Breaking? | Deprecation Period | Priority |
| :---- | :---- | :---- | :---- | :---- |
| GitHub Repository | YES | Low (redirects) | N/A | P0 |
| Go Module Paths | YES | HIGH | 6 months | P0 |
| Container Images | YES | HIGH | 1 months | P0 |
| API Paths | NO\* | \- | \- | \- |
| Python Package | NO | \- | \- | \- |
| K8s Manifests | NO\*\* | \- | \- | \- |
| Documentation | YES | Low | Immediate | P1 |
| CI/CD | YES | Low | With repo rename | P0 |
| Database Names | NO | \- | \- | \- |
| Config Files | BOTH | Low | 12 months | P2 |
| Env Variables | BOTH | Low | 12 months | P2 |

**Notes:**

- \*API Paths: Keep existing, ADD `/ai_assets_catalog/` alias for catalog  
- \*\*K8s Manifests: Keep component names unchanged, optionally ADD `app.kubernetes.io/part-of: kubeflow-hub` labels

---

## Recommendations Summary

### MUST DO

1. **Rename repository** to `kubeflow/hub`  
2. **Update Go module paths** with proper version bump  
3. **Publish containers to new registry** after transition announcement period  
4. **Add `/ai_assets_catalog/` alias path** for catalog component  
5. **Create comprehensive migration documentation** emphasizing what's NOT changing  
6. **Update documentation** to explain Kubeflow Hub as umbrella grouping components

### SHOULD DO

1. **Add Hub context labels** to K8s resources (`app.kubernetes.io/part-of: kubeflow-hub`)  
2. **Support both old and new config files/environment variables**  
3. **Maintain deprecation period** of at least 6 months for container images  
4. **Coordinate with kubeflow/manifests** for documentation updates

### SHOULD NOT DO (Component Names Remain Unchanged)

1. **DO NOT rename API paths** \- Keep `/api/model_registry/v1alpha3/` and `/model_catalog/`  
2. **DO NOT rename Python package** \- Keep `model-registry` (accurately describes component)  
3. **DO NOT rename K8s service names** \- Keep `model-registry-ui`, `catalog-service`, etc.  
4. **DO NOT rename database/table names** \- Internal implementation details  
5. **DO NOT remove old container images** before transition period complete

### MUST NOT DO

1. **Break API contracts** without proper deprecation  
2. **Remove old artifacts** before minimum transition period  
3. **Ignore downstream impact** on KServe, Pipelines, external users  
4. **Create confusion** about what Kubeflow Hub means vs. component names

---

## Decision

**Pending community review and approval.**

This ADR should be discussed in:

- Kubeflow Model Registry community meeting  
- GitHub discussion on kubeflow/community

---

## References

- [KEP-907: Model Registry Renaming](https://github.com/kubeflow/community/pull/907)  
- [Community Proposal](https://github.com/kubeflow/community/tree/master/proposals/907-model-registry-renaming)  
- [Semantic Versioning](https://semver.org/)  
- [Go Module Versioning](https://go.dev/doc/modules/version-numbers)

---

## Appendix A: File Change Inventory

### High-Level Statistics

- **Go files requiring import updates**: 325+ files  
- **Total import occurrences**: 889+  
- **Container image references**: 24 files  
- **Kubernetes manifests**: 50+ files  
- **CI/CD workflows**: 20+ files  
- **Documentation files**: 15+ files  
- **Python package files**: 30+ files

### Critical Path Files

1. `/go.mod` \- Root module definition  
2. `/Makefile` \- Build system  
3. `/Dockerfile` \- Container build  
4. `/.github/workflows/build-and-push-image.yml` \- CI/CD  
5. `/manifests/kustomize/base/kustomization.yaml` \- K8s base  
6. `/clients/python/pyproject.toml` \- Python package  
7. `/clients/ui/frontend/package.json` \- UI package

---

## Appendix B: Migration Script Outline

```shell
#!/bin/bash
# migrate-to-kubeflow-hub.sh
# Outline for automated migration assistance

# 1. Update Go imports
find . -name "*.go" -exec sed -i '' \
  's|github.com/kubeflow/model-registry|github.com/kubeflow/hub|g' {} \;

# 2. Update go.mod files
for f in $(find . -name "go.mod"); do
  sed -i '' 's|github.com/kubeflow/model-registry|github.com/kubeflow/hub|g' "$f"
done

# 3. Update container references
find . -name "*.yaml" -o -name "*.yml" | xargs sed -i '' \
  's|ghcr.io/kubeflow/model-registry|ghcr.io/kubeflow/hub|g'

# 4. Run go mod tidy
go mod tidy

# 5. Verify builds
make build
make test
```

---

## Appendix C: Communication Template

### Community Announcement

```
# Kubeflow Model Registry is becoming Kubeflow Hub!

The Kubeflow community has approved renaming "Model Registry" to "Kubeflow Hub"
to better reflect our expanded capabilities for model registry tracking AND
model catalog functionality.

**Important: Kubeflow Hub is an umbrella name grouping our AI asset management
components (Model Registry and Catalog). Component-specific names remain unchanged
to minimize breaking changes.**

## What's Changing
- **Repository**: github.com/kubeflow/model-registry → github.com/kubeflow/hub
  - GitHub automatically redirects old URLs
  - Go module paths update in next major version
- **Container images**: Published to new container registry
  - New: ghcr.io/kubeflow/hub/*
  - Legacy: ghcr.io/kubeflow/model-registry/* (deprecated but supported)
- **Documentation**: Updated to explain Kubeflow Hub architecture

## What's NOT Changing (Zero Breaking Changes)
- **API paths**: `/api/model_registry/v1alpha3/` and `/model_catalog/` remain unchanged
  - New catalog alias: `/ai_assets_catalog/` (routes to same handler)
- **Python SDK**: `model-registry` package name stays the same
- **Kubernetes resources**: Service names like `model-registry-ui` and `catalog-service` unchanged
- **Database names**: No schema changes required

## Timeline
- [Date]: Repository rename (old URLs auto-redirect)
- [Date]: Container registry rename
- [Date + 6+ months]: Deprecate legacy container registry

## Migration Guide
See: [link to migration documentation]

## Questions?
- GitHub Discussion: [link]
- Slack: #kubeflow-model-registry
```

---

*Document created: 2026-02-02* *Author: Community Technical Analysis* *Version: 1.0*  
