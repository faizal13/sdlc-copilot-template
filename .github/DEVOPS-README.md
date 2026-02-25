# GitHub Actions Workflows & Release Process

This document outlines the end-to-end workflow for repository management, branching, CI/CD, release, and rollback using GitHub Actions. It details the purpose, triggers, and key operations of each workflow, and provides a step-by-step guide for typical development and release cycles.

---

## Repository Creation & Initial Setup

1. **Create a New Repository**
   - Use the [repo_creation_form.yml](https://github.com/rakbank-internal/repo-creation-automation/actions/workflows/repo_creation_form.yml) workflow to create a new repository.
   - The default branch will be set to `main`.

2. **Add Source Code**
   - Add your source code to the `main` branch, by following the process outlined below.

---

## Branching & Release Workflow

### 1. Create Release Branch

- **Workflow:** ` Create Release Branch`
- **Purpose:** Create a dedicated release branch to manage and isolate release-specific changes.
- **Trigger:** Manually via `workflow_dispatch` (requires approval).
- **Example:**  
  ```
  release/auth-1.0
  ```
- **Description:**  
  This workflow creates a new release branch from `main`. Approval is required to ensure only authorized personnel can initiate releases.

---

### 2. Feature Development

- **Manual Step:**  
  Spawn a feature branch from the release branch:
  ```
  git checkout -b feature/delta-team-auth-01 release/auth-1.0
  ```
- **Development:**  
  Developers make changes on their feature branch.

---

### 3. CI/CD for Feature Branches

- **Workflow:** ` CICD Orchestrator`
- **Purpose:** Build, test, and deploy artifacts to lower environments.
- **Trigger:** Manually or automatically on PRs targeting `main`.
- **Note:**  
  Deployments to higher environments are auto-skipped for `feature/*` branches.

---

### 4. Merging Feature to Release

- **PR:**  
  Once changes are ready, raise a PR from `feature/*` to `release/*`.
- **Approval:**  
  PR approval is at the discretion of engineering leads. Use squash and merge.
- **Validation:**  
  The ` Validate PR Title` workflow ensures PR titles follow conventions.

---

### 5. CI/CD for Release Branches

- **Workflow:** ` CICD Orchestrator`
- **Purpose:** Deploy to higher environments after merging into `release/*`.
- **Trigger:** Manually invoked by teams.

---

### 6. Merging Release to Main

- **PR:**  
  After successful testing in higher environments, raise a PR from `release/*` to `main`.
- **Workflow:**  
  The ` CICD Orchestrator` is auto-triggered, rebuilding images and promoting them through environments based on approval gates.
- **Merge:**  
  Once deployed to production, merge the PR into `main`.

---

### 7. Tagging & Release

- **Workflow:** ` Release`
- **Purpose:** Automate version tagging and release management.
- **Trigger:** Automatically on merge to `main`.
- **Description:**  
  Creates or increments tags on the `main` branch following semantic versioning and [Conventional Commits](https://www.conventionalcommits.org/) strategy.

#### Tag Creation Examples

| PR Comment                                      | Resulting Tag Creation |
|-------------------------------------------------|-----------------------|
| `fix: Login issue fix`                          | `v1.0.1`              |
| `chore: Updated with comments`                  | _No new tag_          |
| `docs: Created docs for Login mechanism`        | _No new tag_          |
| `feat: Enabling authentication changes`         | `v1.1.0`              |
| `feat!: Switching the authentication from v1 to v2` | `v2.0.0`          |

---

### 8. Rollback

- **Workflow:** ` Rollback Orchestrator`
- **Purpose:** Roll back application and database to a previous stable state.
- **Trigger:** Manually via `workflow_dispatch` with input parameters.
- **Description:**  
  Allows selection of target environment and reverts both application image and database (using mechanisms like container image rollback and Liquibase checkpoint IDs).

---

### 9. Deleting Release Branches

- **Workflow:** `Delete Release Branch`
- **Purpose:** Safely delete release branches after deployment.
- **Trigger:** Manually via `workflow_dispatch` with required approval.
- **Description:**  
  Only authorized personnel (e.g., lead developer or `release-branch-ops` group) can approve branch deletion.

---

## Additional Notes

- **PR Title Validation:**  
  Every PR from `feature/*` to `release/*` or from `release/*` to `main` is validated for PR title correctness by the `Validate PR Title` workflow.
- **Release Configuration:**  
    The release automation `Release` is powered by [`.releaserc.json`](../../.releaserc.json), which configures semantic-release to manage versioning, changelogs, and GitHub releases. All DevOps engineers are encouraged to adopt this approach in their respective repositories to ensure consistency, traceability, and automation across projects.
- **Tag Inheritance:**  
  Any subsequent release branch creation from `main` will use the latest tag as its parent, aiding in traceability.

- **CODEOWNERS Adoption:**  
    Add a `.github/CODEOWNERS` file specifying repository and project-specific leads to enforce code review and approval workflows. This ensures the right stakeholders are automatically requested for reviews on relevant files and directories.
- **Process Flexibility:**  
    DevOps engineers may tailor the workflow to suit the nature of the product or process (e.g., monolith vs. microservice architectures), including adopting different branching strategies such as Git Flow, trunk-based development, or simplified release branching. Teams should select a branching model that aligns with their deployment frequency, team size, and project complexity, ensuring alignment with project-specific requirements and best practices.

- **Dedicated Approval Environment:**  
    Create a separate environment (e.g., `release-branch-ops`) in GitHub with designated leads as approvers. This ensures that only authorized personnel can approve critical actions like release branch creation and deletion, enhancing control and auditability.
---

## Change History

| Date       | Author               | Description        |
|------------|----------------------|--------------------|
| 2025-06-12 | xmmikkil-rakbank     | Initial draft      |
| 2025-06-13 | xmmikkil-rakbank     | Reorganized & expanded process |
