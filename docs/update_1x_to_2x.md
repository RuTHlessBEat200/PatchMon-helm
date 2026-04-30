# Upgrading from v1 to v2

> **This is not a drop-in upgrade.** PatchMon v2 is a major release with significant architectural changes. Simply bumping the chart version will break your deployment. Read this section carefully before proceeding.
>
> More information at: https://docs.patchmon.net/books/patchmon-application-documentation/page/migrating-from-142-to-200

**What changed in v2:**

- The separate `backend` and `frontend` containers have been merged into a single `server` container. The frontend static files are now embedded in the Go binary and served directly by the server.
- Agent binaries are now embedded in the container image — the agent files PVC is no longer needed.
- Branding assets are now stored in the database — the assets volume is no longer needed.
- The chart values structure has changed: all `backend:` and `frontend:` keys are replaced by a single `server:` key.
- The server runs on port `3000` (previously backend on `3001`, frontend on `3000`).
- Guacamole daemon (`guacd`) is now a required dependency, deployed as a separate pod.

**Migration steps:**

1. Review `values.yaml` or `values-prod.yaml` in this chart for the new configuration structure before making any changes.

2. Update your values overrides — rename `backend:` to `server:` and remove any `frontend:` block entirely. The ingress no longer needs separate `/` and `/api` paths; everything routes to `server` on port `3000`.

3. Delete the old Deployment resources (Kubernetes does not allow changing a resource kind in-place):
   ```bash
   kubectl delete deployment <release>-backend <release>-frontend -n <namespace>
   ```

4. Delete the old agent files PVC if present (no longer used):
   ```bash
   kubectl delete pvc <release>-agent-files -n <namespace>
   ```

5. Run `helm upgrade`.

Refer to [values-prod.yaml](values-prod.yaml) for a complete working example of the v2 values structure.

---

> **Important: Keep `server.replicaCount` at `1`.**
> Agents establish persistent connections to a specific server pod. With multiple replicas, an agent may connect to pod A while the ingress routes your browser session to pod B — causing agents to appear offline even though they are actively connected. Until a shared connection state backend is implemented, horizontal scaling of the server is not supported. This issue is not related to the Helm chart but to the PatchMon application itself. This PR will fix it: https://github.com/PatchMon/PatchMon/pull/722
