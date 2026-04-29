# Update Procedure

This guide describes how to update the PatchMon Helm chart when a new version is released.

## Prerequisites

- Access to the Helm chart repository
- Knowledge of the new PatchMon version number

## Update Steps

### 1. Update Chart Version

Edit `Chart.yaml` and update the following fields:

```yaml
version: 2.1.0        # Increment chart version (see version scheme below)
appVersion: v2.0.2    # Update to new PatchMon version
```

**Chart Version Scheme (Semantic Versioning):**

The chart version follows `MAJOR.MINOR.PATCH`:

- **MAJOR** (X.0.0): Breaking changes requiring manual intervention
  - PostgreSQL major version upgrade (e.g., 17 → 18)
  - Redis major version upgrade (e.g., 7 → 8)
  - Significant architectural changes
  - Changes to PVC structure or storage requirements

- **MINOR** (1.X.0): New features or application updates
  - PatchMon application version bump (appVersion change)
  - New configuration options added
  - New features in the chart (e.g., adding HPA support)
  - Non-breaking template changes

- **PATCH** (1.3.X): Bugfixes and minor improvements
  - Chart template bugfixes
  - Documentation updates
  - Security context adjustments
  - Resource limit tweaks
  - No appVersion change

**Examples:**
- `1.0.0 → 2.0.0`: PostgreSQL 18 → 19 upgrade (MAJOR)
- `1.0.0 → 1.1.0`: PatchMon v1.4.1 → v1.4.2 (MINOR)
- `1.0.0 → 1.0.1`: Fixed probe configuration (PATCH)

### 2. Update Image Tags

Edit `values.yaml` and update the image tag for server:

#### Server Image
```yaml
server:
  image:
    registry: ghcr.io
    repository: patchmon/patchmon-server
    tag: "2.0.2"      # Update this
    pullPolicy: IfNotPresent
```

### 3. Lint Chart

Lint the chart to ensure it's valid:

```bash
helm lint .
```

Test template rendering:

```bash
helm template patchmon . --values values.yaml
```