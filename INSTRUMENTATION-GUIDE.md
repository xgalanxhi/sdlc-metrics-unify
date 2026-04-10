# CloudBees Unify Workflow Instrumentation Guide

This guide provides copy-paste code snippets for adding CloudBees Unify analytics instrumentation to your workflow.

## Table of Contents

1. [Test Results Publishing](#test-results-publishing)
2. [Security Scanning](#security-scanning)
3. [Build Artifact Registration](#build-artifact-registration)
4. [Artifact Labeling](#artifact-labeling)
5. [Build Evidence Publishing](#build-evidence-publishing)
6. [Deployment Registration](#deployment-registration)
7. [Deployment Evidence Publishing](#deployment-evidence-publishing)
8. [Step Kind Attributes](#step-kind-attributes)

---

## Test Results Publishing

**Dashboard**: Test Insights

**Action**: `cloudbees-io/publish-test-results@v2`

**Location**: After test execution steps in `test` job

```yaml
- name: Publish Test Results
  uses: cloudbees-io/publish-test-results@v2
  if: always()
  with:
    test-type: JUNIT
    results-path: junit.xml
```

**Parameters**:
- `test-type`: Test framework format (JUNIT, jest, go, playwright, etc.)
- `results-path`: Path to test results file
- `if: always()`: Ensures results are published even if tests fail

**Supported Test Types**: JUNIT, Jest, Go, Playwright, MSTest, TestNG, Selenium, JMeter, ProdPerfect, Tosca

---

## Security Scanning

**Dashboard**: Security Insights

### Option 1: Secret Scanning with Gitleaks

```yaml
- name: Secret scanning with Gitleaks
  uses: cloudbees-io/gitleaks-plugin@v1
```

### Option 2: Container Scanning with Trivy

```yaml
- name: Container scanning with Trivy
  uses: cloudbees-io/trivy-plugin@v1
  with:
    image: docker.io/myorg/myapp:${{ cloudbees.scm.sha }}
```

### Option 3: SAST Scanning with SonarQube

```yaml
- name: SAST scanning with SonarQube
  uses: cloudbees-io/sonarqube-plugin@v1
  with:
    server-url: ${{ secrets.SONARQUBE_URL }}
    token: ${{ secrets.SONARQUBE_TOKEN }}
    project-key: my-project
```

**Available Security Actions**:
- `cloudbees-io/gitleaks-plugin@v1` - Secret detection
- `cloudbees-io/trivy-plugin@v1` - Container scanning
- `cloudbees-io/sonarqube-plugin@v1` - Code quality and SAST
- `cloudbees-io/snyk-sast-scan-code@v1` - Snyk SAST
- `cloudbees-io/snyk-sca-scan-dependency@v1` - Snyk dependency scanning
- `cloudbees-io/gosec-plugin@v1` - Golang security scanning

---

## Build Artifact Registration

**Dashboard**: Software Delivery Activity, Environment Inventory (foundation for DORA metrics)

**Action**: `cloudbees-io/register-build-artifact@v2`

**Location**: After build step in `build` job

**Important**: You must add job outputs to export the artifact ID for deployment tracking.

### Step 1: Add job outputs

At the top of the `build` job, uncomment or add:

```yaml
build:
  needs:
    - test
    - lint
    - security-scan
  outputs:
    version: ${{ steps.version.outputs.version }}
    artifact_id: ${{ steps.register-artifact.outputs.artifact-id }}
  steps:
    # ... rest of steps
```

### Step 2: Add register-build-artifact action

After the "Generate version and build" step:

```yaml
- name: Register Build Artifact in CloudBees Unify
  id: register-artifact
  uses: cloudbees-io/register-build-artifact@v2
  with:
    name: ${{ cloudbees.scm.repositoryUrl }}
    url: https://artifacts.example.com/${{ env.APP_NAME }}/${{ steps.version.outputs.version }}
    version: ${{ steps.version.outputs.version }}
    type: Binary
```

**Parameters**:
- `name`: Artifact name (use repository URL for consistency)
- `url`: Location where artifact can be accessed
- `version`: Artifact version
- `type`: Artifact type (Binary, Docker, Maven, NPM, etc.)
- `digest`: (optional) SHA256 checksum for verification

**Note**: The `id: register-artifact` is required so you can reference `${{ steps.register-artifact.outputs.artifact-id }}` in deployment jobs.

---

## Artifact Labeling

**Dashboard**: Software Delivery Activity (metadata categorization)

**Action**: `cloudbees-io/label-artifact-version@v1`

**Location**: After `register-build-artifact@v2` in `build` job

```yaml
- name: Add Labels to Artifact
  uses: cloudbees-io/label-artifact-version@v1
  with:
    artifact-id: ${{ steps.register-artifact.outputs.artifact-id }}
    labels: ${{ cloudbees.scm.branch }},nodejs,express,automated
```

**Parameters**:
- `artifact-id`: Artifact ID from `register-build-artifact@v2` output
- `labels`: Comma-separated labels for categorization

**Recommended Labels**:
- Branch name: `${{ cloudbees.scm.branch }}`
- Technology stack: `nodejs`, `python`, `java`, etc.
- Build type: `automated`, `manual`
- Environment tier: `production`, `staging`

---

## Build Evidence Publishing

**Dashboard**: Evidence tab (compliance and audit)

**Action**: `cloudbees-io/publish-evidence-item@v1`

**Location**: After artifact registration in `build` job

```yaml
- name: Publish Build Evidence
  uses: cloudbees-io/publish-evidence-item@v1
  with:
    content: |-
      # Build Evidence Report

      ## Artifact Details
      - **Repository**: ${{ cloudbees.scm.repositoryUrl }}
      - **Version**: ${{ steps.version.outputs.version }}
      - **Artifact ID**: ${{ steps.register-artifact.outputs.artifact-id }}
      - **Type**: NPM Package
      - **Branch**: ${{ cloudbees.scm.branch }}

      ## Build Configuration
      - **Node Version**: ${{ env.NODE_VERSION }}
      - **Package**: ${{ env.APP_NAME }}-${{ steps.version.outputs.version }}.tar.gz

      ## Quality Gates
      - **Unit Tests**: ✅ Passed
      - **Linting**: ✅ Completed
      - **Security Scan**: ✅ Completed

      ## Workflow Summary
      - **Commit**: ${{ cloudbees.scm.sha }}
      - **Workflow Run**: ${{ cloudbees.run_id }}
```

**Parameters**:
- `content`: Markdown-formatted evidence document

**Best Practices**:
- Include artifact IDs for traceability
- Document quality gate results
- Add timestamps and workflow run IDs
- Use Markdown formatting for readability

---

## Deployment Registration

**Dashboard**: DORA Metrics, Software Delivery Activity, Environment Inventory

**Action**: `cloudbees-io/register-deployed-artifact@v2`

**Location**: After deployment steps in deployment jobs (`deploy-dev`, `deploy-staging`, `deploy-production`)

### Basic Deployment Registration

```yaml
- name: Register Deployed Artifact to Staging
  uses: cloudbees-io/register-deployed-artifact@v2
  with:
    artifact-id: ${{ needs.build.outputs.artifact_id }}
    labels: automated-deployment
```

### Production Deployment with Failure Tracking

For accurate Change Failure Rate metrics, use `if: always()` to track both successful and failed deployments:

```yaml
- name: Register Deployed Artifact to Production
  if: always()
  uses: cloudbees-io/register-deployed-artifact@v2
  with:
    artifact-id: ${{ needs.build.outputs.artifact_id }}
    labels: automated-deployment
```

**Parameters**:
- `artifact-id`: Artifact ID from build job output (`needs.build.outputs.artifact_id`)
- `target-environment`: (optional) Environment name if not using job-level `environment:` attribute
- `labels`: (optional) Comma-separated labels

**Important**:
- The `artifact-id` parameter links deployments to builds (required for DORA metrics)
- Use `if: always()` in production to track failed deployments for Change Failure Rate
- Ensure the deployment job has `environment: production` attribute at the job level
- CloudBees automatically detects deployment failures based on step exit codes

---

## Deployment Evidence Publishing

**Dashboard**: Evidence tab (compliance and audit)

**Action**: `cloudbees-io/publish-evidence-item@v1`

**Location**: After deployment validation in deployment jobs

```yaml
- name: Publish Deployment Evidence
  uses: cloudbees-io/publish-evidence-item@v1
  with:
    content: |-
      # Production Deployment Evidence

      ## Deployment Details
      - **Version**: ${{ needs.build.outputs.version }}
      - **Environment**: Production
      - **Artifact ID**: ${{ needs.build.outputs.artifact_id }}

      ## Validation
      - **Smoke Tests**: ✅ Passed
      - **Post-deployment Checks**: ✅ Passed

      ## Workflow Info
      - **Run ID**: ${{ cloudbees.run_id }}
```

---

## Step Kind Attributes

**Dashboard**: Software Delivery Activity (step categorization)

**Purpose**: Classify workflow steps by purpose for better analytics

Add the `kind:` attribute to steps to classify them:

### Test Steps

```yaml
- name: Install dependencies and run tests
  kind: test
  uses: docker://node:18
  shell: sh
  run: |
    npm ci
    npm run test:ci
```

### Build Steps

```yaml
- name: Generate version and build
  id: version
  kind: build
  uses: docker://node:18
  shell: sh
  run: |
    # Build commands here
```

### Deploy Steps

```yaml
- name: Deploy to Production
  kind: deploy
  uses: docker://node:18
  shell: sh
  run: |
    # Deployment commands here
```

**Supported Kind Values**:
- `test`: Test execution steps
- `build`: Build and compilation steps
- `deploy`: Deployment steps

**When to Use**:
- Add `kind: test` to steps that execute test suites
- Add `kind: build` to steps that compile code or create artifacts
- Add `kind: deploy` to steps that deploy to environments
- The `kind:` attribute is optional but recommended for better categorization

---

## Complete Example

For a fully instrumented workflow example, see `.cloudbees/workflows/ci-cd-complete.yaml` in this repository.

## CloudBees Context Variables

Commonly used context variables in CloudBees workflows:

- `${{ cloudbees.scm.sha }}` - Commit SHA
- `${{ cloudbees.scm.branch }}` - Branch name
- `${{ cloudbees.scm.ref }}` - Git reference
- `${{ cloudbees.scm.repositoryUrl }}` - Repository URL
- `${{ cloudbees.run_id }}` - Workflow run ID
- `${{ cloudbees.workspace }}` - Workspace directory
- `${{ cloudbees.actor }}` - User who triggered the workflow
- `${{ cloudbees.event.inputs.* }}` - Workflow dispatch inputs

## Output Capture Pattern

To pass data between jobs (like artifact IDs):

1. Define job outputs:
```yaml
build:
  outputs:
    artifact_id: ${{ steps.register-artifact.outputs.artifact-id }}
```

2. Write to step output file:
```yaml
printf "%s" "$VERSION" > $CLOUDBEES_OUTPUTS/version
```

3. Reference in dependent jobs:
```yaml
deploy:
  needs: build
  steps:
    - name: Deploy
      run: echo "${{ needs.build.outputs.artifact_id }}"
```

## Additional Resources

- **CloudBees Actions Overview**: https://docs.cloudbees.com/docs/cloudbees-unify/latest/actions
- **Register Build Artifact**: https://docs.cloudbees.com/docs/cloudbees-unify/latest/artifact-management/register-build-artifact
- **Register Deployed Artifact**: https://docs.cloudbees.com/docs/cloudbees-unify/latest/artifact-management/register-deployed-artifact
- **Publish Test Results**: https://docs.cloudbees.com/docs/cloudbees-unify/latest/testing/publish-test-results
- **Security Actions**: https://docs.cloudbees.com/docs/cloudbees-unify/latest/security
