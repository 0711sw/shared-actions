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

### short-sha

Returns the short (7 character) commit SHA as an output.

```yaml
- name: Get short SHA
  id: sha
  uses: 0711sw/shared-actions/short-sha@main

- name: Use it
  run: echo "Short SHA is ${{ steps.sha.outputs.sha }}"
```

### ecr-scan

Waits for ECR image scan to complete and checks for vulnerabilities.

```yaml
- uses: 0711sw/shared-actions/ecr-scan@main
  with:
    repository: my-org/my-repo
    image-tag: abc1234
    fail-on-critical: true   # optional, default: true
    fail-on-high: false      # optional, default: false
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
