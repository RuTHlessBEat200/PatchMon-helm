# PatchMon Helm Chart

A production-ready Helm chart for deploying PatchMon, a comprehensive Linux patch monitoring and management system.

## Features

- 🚀 **Complete Stack Deployment**: PostgreSQL 18-alpine, Redis 8-alpine, Backend API, and Frontend UI
- 🔧 **Highly Configurable**: Extensive values.yaml with sensible defaults
- 🔐 **Security First**: Non-root containers, auto-generated secrets (preserved on upgrades), seccomp profiles, minimal capabilities
- 📈 **Auto-scaling**: HPA support for backend and frontend
- 🏷️ **Flexible Naming**: Global name overrides for multi-tenant deployments
- 💾 **Persistent Storage**: Configurable storage classes and sizes
- 🔄 **Dependency Management**: Built-in init containers for service dependencies with security contexts
- 🌐 **Ingress Support**: TLS and cert-manager integration
- 📊 **Resource Management**: Configurable resource limits and requests
- ⚡ **Production Ready**: Complies with Kubernetes restricted PodSecurity policy

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistent volumes)
- (Optional) cert-manager for automatic TLS certificate management
- (Optional) Metrics Server for HPA functionality

## Installation

### Quick Start

```bash
# Install from OCI registry with default values (latest version)
helm install patchmon oci://ghcr.io/ruthlessbeat200/charts/patchmon \
  --namespace patchmon \
  --create-namespace

# Install with custom values
helm install patchmon oci://ghcr.io/ruthlessbeat200/charts/patchmon \
  --namespace patchmon \
  --create-namespace \
  --values custom-values.yaml

# Or install a specific version
helm install patchmon oci://ghcr.io/ruthlessbeat200/charts/patchmon \
  --version 1.1.0 \
  --namespace patchmon \
  --create-namespace

# Pull the chart first, then install
helm pull oci://ghcr.io/ruthlessbeat200/charts/patchmon --untar
helm install patchmon ./patchmon -n patchmon --create-namespace -f custom-values.yaml
```

**Note**: Browse available versions at https://github.com/RuTHlessBEat200/PatchMon-helm/releases

### Production Deployment

For production deployments, use external secret management instead of auto-generated secrets. See the [production example](values-prod.yaml) for a complete configuration.

**Secret Management Best Practices:**

The chart supports integration with secure secret management tools:

- **[KSOPS](https://github.com/viaduct-ai/kustomize-sops)** - Encrypt secrets in Git using Mozilla SOPS
- **[Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)** - Encrypt secrets that only the cluster can decrypt
- **[External Secrets Operator](https://external-secrets.io/)** - Sync secrets from external secret stores (Vault, AWS Secrets Manager, etc.)
- **[Vault](https://www.vaultproject.io/)** - Enterprise-grade secret management

**Production example** ([values-prod.yaml](values-prod.yaml)):

```yaml
global:
  storageClass: "proxmox-data"

fullnameOverride: "patchmon-prod"

# Reference existing secrets (managed by KSOPS or other tools)
backend:
  env:
    serverProtocol: https
    serverHost: patchmon.example.com
    serverPort: "443"
    corsOrigin: https://patchmon.example.com
  existingSecret: "patchmon-secrets"
  existingSecretJwtKey: "jwt-secret"

database:
  auth:
    existingSecret: patchmon-secrets
    existingSecretPasswordKey: postgres-password

redis:
  auth:
    existingSecret: patchmon-secrets
    existingSecretPasswordKey: redis-password

# Disable auto-generated secrets
secret:
  create: false

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: patchmon.example.com
      paths:
        - path: /
          pathType: Prefix
          service:
            name: frontend
            port: 3000
  tls:
    - secretName: patchmon-tls
      hosts:
        - patchmon.example.com
```

**Deploy with production values:**

```bash
helm install patchmon oci://ghcr.io/ruthlessbeat200/charts/patchmon \
  --namespace patchmon \
  --create-namespace \
  --values values-prod.yaml
```

### Basic Configuration

Create a `values.yaml` file with your configuration:

```yaml
# Basic configuration
fullnameOverride: "patchmon-hosting1"  # All resources will be prefixed with this name

global:
  storageClass: "proxmox-data"

backend:
  env:
    serverProtocol: https
    serverHost: patchmon.example.com
    serverPort: "443"
    corsOrigin: https://patchmon.example.com

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: patchmon.example.com
      paths:
        - path: /
          pathType: Prefix
          service:
            name: frontend
            port: 3000
  tls:
    - secretName: patchmon-tls
      hosts:
        - patchmon.example.com
```

Then install:

```bash
helm install patchmon ./patchmon -n patchmon --create-namespace -f values.yaml
```

## Configuration

### Global Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Global Docker registry override (takes priority over component registries) | `""` |
| `global.imagePullSecrets` | Global image pull secrets | `[]` |
| `global.storageClass` | Global storage class for all PVCs | `""` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full resource names | `""` |

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `database.enabled` | Enable PostgreSQL deployment | `true` |
| `database.image.repository` | PostgreSQL image repository | `postgres` |
| `database.image.tag` | PostgreSQL image tag | `18-alpine` |
| `database.auth.database` | Database name | `patchmon_db` |
| `database.auth.username` | Database user | `patchmon_user` |
| `database.auth.password` | Database password (auto-generated if empty) | `""` |
| `database.persistence.size` | Database PVC size | `5Gi` |
| `database.persistence.storageClass` | Storage class for database | Uses global |
| `database.updateStrategy.type` | StatefulSet update strategy | `RollingUpdate` |
| `database.resources.requests.memory` | Memory request | `128Mi` |
| `database.resources.limits.memory` | Memory limit | `1Gi` |

### Redis Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `redis.enabled` | Enable Redis deployment | `true` |
| `redis.image.repository` | Redis image repository | `redis` |
| `redis.image.tag` | Redis image tag | `8-alpine` |
| `redis.auth.password` | Redis password (auto-generated if empty) | `""` |
| `redis.persistence.size` | Redis PVC size | `5Gi` |
| `redis.persistence.storageClass` | Storage class for Redis | Uses global |
| `redis.updateStrategy.type` | StatefulSet update strategy | `RollingUpdate` |
| `redis.resources.requests.memory` | Memory request | `10Mi` |
| `redis.resources.limits.memory` | Memory limit | `512Mi` |

### Backend Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `backend.enabled` | Enable backend deployment | `true` |
| `backend.image.registry` | Backend image registry | `ghcr.io` |
| `backend.image.repository` | Backend image repository | `patchmon/patchmon-backend` |
| `backend.image.tag` | Backend image tag | `1.4.0` |
| `backend.replicaCount` | Number of backend replicas | `1` (>1 requires RWX storage) |
| `backend.jwtSecret` | JWT secret (auto-generated if empty) | `""` |
| `backend.env.serverProtocol` | Server protocol | `http` |
| `backend.env.serverHost` | Server hostname | `patchmon.example.com` |
| `backend.env.serverPort` | Server port | `80` |
| `backend.env.corsOrigin` | CORS origin URL | `http://patchmon.example.com` |
| `backend.persistence.size` | Agent files PVC size | `5Gi` |
| `backend.autoscaling.enabled` | Enable HPA for backend | `false` |
| `backend.autoscaling.minReplicas` | Minimum replicas | `1` |
| `backend.autoscaling.maxReplicas` | Maximum replicas | `10` |
| `backend.resources.requests.memory` | Memory request | `256Mi` |
| `backend.resources.limits.memory` | Memory limit | `2Gi` |

### Frontend Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `frontend.enabled` | Enable frontend deployment | `true` |
| `frontend.image.registry` | Frontend image registry | `ghcr.io` |
| `frontend.image.repository` | Frontend image repository | `patchmon/patchmon-frontend` |
| `frontend.image.tag` | Frontend image tag | `1.4.0` |
| `frontend.replicaCount` | Number of frontend replicas | `1` |
| `frontend.autoscaling.enabled` | Enable HPA for frontend | `false` |
| `frontend.autoscaling.minReplicas` | Minimum replicas | `1` |
| `frontend.autoscaling.maxReplicas` | Maximum replicas | `10` |
| `frontend.resources.requests.memory` | Memory request | `50Mi` |
| `frontend.resources.limits.memory` | Memory limit | `512Mi` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class name | `""` (empty, uses default) |
| `ingress.annotations` | Ingress annotations | cert-manager disabled by default |
| `ingress.hosts` | Ingress hosts configuration | `patchmon.example.com` |
| `ingress.tls` | TLS configuration | Commented out by default |

## Advanced Configuration

### Multi-Tenant Deployment

Deploy multiple instances with name prefixes:

```yaml
fullnameOverride: "patchmon-tenant1"

backend:
  env:
    serverHost: tenant1.patchmon.example.com
    corsOrigin: https://tenant1.patchmon.example.com

ingress:
  hosts:
    - host: tenant1.patchmon.example.com
      # ... rest of config
```

### Custom Image Registry

Use a custom registry for all images:

```yaml
global:
  imageRegistry: "registry.example.com"
```

This will override component-specific registries and pull all images from your registry:
- `registry.example.com/postgres:18-alpine`
- `registry.example.com/redis:8-alpine`
- `registry.example.com/patchmon/patchmon-backend:1.4.0`
- `registry.example.com/patchmon/patchmon-frontend:1.4.0`
- `registry.example.com/busybox:latest` (init containers)

Without `global.imageRegistry`, components use their default registries:
- Database/Redis: `docker.io`
- Backend/Frontend: `ghcr.io`

### External Secrets

Use existing secrets instead of auto-generated ones:

```yaml
database:
  auth:
    existingSecret: "my-db-secret"
    existingSecretPasswordKey: "password"

redis:
  auth:
    existingSecret: "my-redis-secret"
    existingSecretPasswordKey: "password"

backend:
  existingSecret: "my-backend-secret"
  existingSecretJwtKey: "jwt-secret"
```

### Enable Auto-scaling

```yaml
backend:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 20
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 80

frontend:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 80
```

### Disable Components

```yaml
# Use external database
database:
  enabled: false

backend:
  env:
    # Configure external database connection
```

## Upgrading

```bash
# Upgrade with new values
helm upgrade patchmon oci://ghcr.io/ruthlessbeat200/charts/patchmon \
  -n patchmon \
  -f values.yaml

# Upgrade and wait for rollout
helm upgrade patchmon oci://ghcr.io/ruthlessbeat200/charts/patchmon \
  -n patchmon \
  -f values.yaml \
  --wait --timeout 10m
```

**Secret Handling on Upgrades:**

Auto-generated secrets are **automatically preserved** across upgrades using Helm's `lookup` function. This prevents authentication failures when upgrading:

- **First install**: Generates random passwords for database, Redis, and JWT
- **Upgrades**: Reuses existing passwords from the cluster
- **Manual override**: Set explicit passwords in `values.yaml` to override

It's still recommended to back up secrets before major upgrades:

```bash
kubectl get secret -n patchmon -o yaml > patchmon-secrets-backup.yaml
```

## Uninstalling

```bash
# Uninstall the release
helm uninstall patchmon -n patchmon

# Clean up PVCs (if needed)
kubectl delete pvc -n patchmon -l app.kubernetes.io/instance=patchmon
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n patchmon
kubectl describe pod <pod-name> -n patchmon
kubectl logs <pod-name> -n patchmon
```

### Check Init Container Logs

```bash
kubectl logs <pod-name> -n patchmon -c wait-for-database
kubectl logs <pod-name> -n patchmon -c wait-for-redis
kubectl logs <pod-name> -n patchmon -c wait-for-backend
```

### Check Service Connectivity

```bash
# Test database connection
kubectl exec -n patchmon -it deployment/patchmon-backend -- nc -zv patchmon-database 5432

# Test Redis connection
kubectl exec -n patchmon -it deployment/patchmon-backend -- nc -zv patchmon-redis 6379

# Check backend health
kubectl exec -n patchmon -it deployment/patchmon-backend -- wget -qO- http://localhost:3001/health
```

### Common Issues

1. **Pods stuck in Init state**: Check if database/redis services are running
2. **PVC binding issues**: Verify storage class is available: `kubectl get sc`
3. **Image pull errors**: Check image registry credentials and imagePullSecrets
4. **Ingress not working**: Verify ingress controller is installed and cert-manager is configured

## Development

### Lint the Chart

```bash
helm lint ./patchmon
```

### Template Rendering

```bash
# Render templates with default values
helm template patchmon ./patchmon

# Render with custom values
helm template patchmon ./patchmon -f custom-values.yaml

# Debug template rendering
helm template patchmon ./patchmon --debug
```

### Dry Run Installation

```bash
helm install patchmon ./patchmon -n patchmon --dry-run --debug
```

## License

This Helm chart is distributed under the same license as PatchMon.

## Support

For issues and questions:
- GitHub Issues: https://github.com/patchmon/patchmon/issues
- Documentation: https://github.com/patchmon/patchmon

## Contributing

Contributions are welcome! Please submit pull requests or issues on GitHub.