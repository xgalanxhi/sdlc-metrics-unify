# CloudBees Unify Metrics Demo Application

This repository demonstrates how to instrument CloudBees Unify workflows to populate all analytics dashboards (Software Delivery Activity, Test Insights, Security Insights, DORA Metrics, and Flow Metrics).

## Quick Start

**Fork this repository and follow these steps:**

1. Fork this repository to your GitHub account
2. Create a component in CloudBees Unify connected to your forked repository
3. Trigger the `CI/CD Pipeline` workflow from the Runs tab

Your analytics dashboards will begin populating with workflow data.

## Repository Structure

### Two-File Approach for Learning

This repository uses a **two-file workflow approach** to help you learn CloudBees Unify instrumentation progressively:

| File | Purpose |
|------|---------|
| `.cloudbees/workflows/ci-cd.yaml` | **Starting point** - Basic CI/CD workflow without CloudBees instrumentation |
| `.cloudbees/workflows/ci-cd-complete.yaml` | **Reference** - Fully instrumented workflow with all analytics integration |
| `INSTRUMENTATION-GUIDE.md` | **Copy-paste snippets** - Code examples for each integration point |

### Recommended Learning Path

1. **Start with `ci-cd.yaml`** on the `main` branch
2. **Follow the TODO comments** marking each integration point
3. **Use `INSTRUMENTATION-GUIDE.md`** for copy-paste code snippets
4. **Compare with `ci-cd-complete.yaml`** when you need a reference

## What This Demo Includes

**Application**:
- Node.js/Express demo application
- Unit tests generating JUnit XML output
- Lint configuration with ESLint
- Package build process creating tarball artifacts

**Workflow Features**:
- Multi-job pipeline (test, lint, security-scan, build, deploy)
- Multi-environment deployment (development, staging, production)
- Production failure simulation via workflow inputs
- Version generation based on git commit count

## CloudBees Unify Instrumentation Points

The workflow includes TODO comments for adding these CloudBees actions:

### 1. Test Results Publishing
**Action**: `cloudbees-io/publish-test-results@v2`  
**Populates**: Test Insights dashboard  
**Location**: After test execution in `test` job

### 2. Security Scanning
**Actions**: `cloudbees-io/gitleaks-plugin@v1`, `cloudbees-io/trivy-plugin@v1`, etc.  
**Populates**: Security Insights dashboard  
**Location**: `security-scan` job

### 3. Build Artifact Registration
**Action**: `cloudbees-io/register-build-artifact@v2`  
**Populates**: Software Delivery Activity, Environment Inventory  
**Location**: After build in `build` job

### 4. Artifact Labeling
**Action**: `cloudbees-io/label-artifact-version@v1`  
**Populates**: Artifact metadata  
**Location**: After artifact registration in `build` job

### 5. Build Evidence Publishing
**Action**: `cloudbees-io/publish-evidence-item@v1`  
**Populates**: Evidence tab  
**Location**: After artifact registration in `build` job

### 6. Deployment Registration
**Action**: `cloudbees-io/register-deployed-artifact@v2`  
**Populates**: DORA Metrics, Software Delivery Activity  
**Location**: After deployment steps in `deploy-*` jobs

### 7. Deployment Evidence Publishing
**Action**: `cloudbees-io/publish-evidence-item@v1`  
**Populates**: Evidence tab  
**Location**: After deployment validation in `deploy-production` job

## Analytics Dashboards Populated

After completing instrumentation, these dashboards will populate:

| Dashboard | Data Source | What It Shows |
|-----------|-------------|---------------|
| **Software Delivery Activity** | Build and deployment registration | Workflow runs, builds, deployments |
| **Test Insights** | Test results publishing | Test execution results and trends |
| **Security Insights** | Security scanning actions | Vulnerability counts and trends |
| **DORA Metrics** | Deployment registration | Deployment frequency, lead time, CFR, MTTR |
| **Flow Metrics** | Jira integration | Work item cycle time, throughput, WIP |

## Prerequisites

To use this demo repository:

- CloudBees Unify organization with component creation permissions
- GitHub account to fork this repository
- Access to CloudBees Unify workflows (all editions support native workflows)
- (Optional) Jira integration for Flow Metrics

## Workflow Execution

The workflow is triggered manually via `workflow_dispatch` with a production deployment status input:

- **Success** (default): Simulates successful production deployment
- **Failure**: Simulates failed production deployment for Change Failure Rate testing

**To trigger**:
1. Navigate to your component in CloudBees Unify
2. Click the **Runs** tab
3. Click **Run workflow**
4. Select production deployment status
5. Click **Run**

## Project Structure

```
.
├── .cloudbees/
│   └── workflows/
│       ├── ci-cd.yaml           # Starting point (with TODOs)
│       └── ci-cd-complete.yaml  # Complete reference
├── src/                          # Demo application source code
├── tests/                        # Unit tests
├── package.json                  # Node.js dependencies
├── INSTRUMENTATION-GUIDE.md      # Copy-paste snippets
└── README.md                     # This file
```

## Application Details

**Technology Stack**:
- Runtime: Node.js 18
- Framework: Express.js
- Testing: Jest with JUnit XML reporter
- Linting: ESLint

**Workflow Jobs**:
1. `test` - Run unit tests
2. `lint` - Run ESLint (continues on error)
3. `security-scan` - Placeholder for security tools
4. `build` - Build application and create tarball
5. `deploy-dev` - Deploy to development (on `develop` branch)
6. `deploy-staging` - Deploy to staging (on `main` branch)
7. `deploy-production` - Deploy to production (on `main` branch after staging)

## Next Steps

1. **Fork this repository** to your GitHub account
2. **Create a component** in CloudBees Unify
3. **Trigger the workflow** to see baseline data
4. **Add instrumentation** following TODO comments and `INSTRUMENTATION-GUIDE.md`
5. **View analytics dashboards** in CloudBees Unify

## Additional Resources

- **CloudBees Unify Documentation**: https://docs.cloudbees.com/docs/cloudbees-unify/latest
- **CloudBees Actions**: https://docs.cloudbees.com/docs/cloudbees-unify/latest/actions
- **Analytics Dashboards**: https://docs.cloudbees.com/docs/cloudbees-unify/latest/analytics
- **Workflow DSL Syntax**: https://docs.cloudbees.com/docs/cloudbees-unify/latest/dsl-syntax

## Support

For questions or issues with this demo repository, refer to the CloudBees Unify documentation or contact CloudBees Professional Services.
