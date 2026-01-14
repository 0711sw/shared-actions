# Shared GitHub Actions

Reusable GitHub Actions for 0711 Software projects.

## Actions

### deploy-ecs

Deploys a new Docker image to an ECS service by updating the task definition.

```yaml
- uses: 0711sw/shared-actions/deploy-ecs@main
  with:
    cluster: my-cluster
    service: my-service
    task-family: my-task-family
    repository: my-org/my-repo
    image-tag: abc1234
```

### cleanup-ecs

Deregisters old ECS task definition revisions, keeping the latest N.

```yaml
- uses: 0711sw/shared-actions/cleanup-ecs@main
  with:
    task-family: my-task-family
    keep: 5  # optional, default: 5
```

### license-report

Generates a `dist/licenses.txt` file from npm dependencies. Optionally prepends a custom `licenses.txt` from the project root.

```yaml
- uses: 0711sw/shared-actions/license-report@main
  with:
    project-root: .  # optional, default: .
```

## License

MIT
