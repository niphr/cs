# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CS is a containerized R environment infrastructure for the CS9 computational framework. It provides Docker images for running R-based epidemiological/healthcare research tasks, with support for:
- Standalone task execution via Apache Airflow on Kubernetes
- Interactive development via Posit Workbench IDE

## Branch Strategy

- `main` - Contains GitHub Actions workflow and CI/CD configuration
- `r-X.Y.Z` branches (e.g., `r-4.5.1`) - Contains Dockerfiles and build scripts for specific R versions

The GitHub Actions workflow in `.github/workflows/r.yml` defines:
- `VERSION` - The R version to build
- `CRAN_CHECKPOINT_BINARY` / `CRAN_CHECKPOINT_SOURCE` - Package repository URLs

The workflow checks out the corresponding `r-X.Y.Z` branch to build images.

**When modifying Dockerfiles or build scripts, work in the appropriate R version branch.**
**When changing the R version or CRAN checkpoint, update `.github/workflows/r.yml` in main.**

## Repository Structure

```
main branch:
├── .github/workflows/r.yml   # CI/CD - defines VERSION and CRAN checkpoints

r-X.Y.Z branches:
└── 1-rbase/
    ├── Dockerfile            # Base R image definition
    ├── build.sh              # Local build script
    └── content/              # Scripts copied into image
```

## Build Commands

### CI/CD Build (GitHub Actions)
Images are built via `.github/workflows/r.yml`:
- Triggered daily at 15:00 UTC or manually via workflow_dispatch
- Pushes to `ghcr.io/niphr/cs/rbase:X.Y.Z`

**GitHub disables the schedule after 60 days without repo activity.** The state
becomes `disabled_inactivity` and every scheduled run stops silently. Nothing in
the run list shows it, because there are no runs to show. Check it, and re-enable
it, with:

```bash
gh api repos/niphr/cs/actions/workflows --jq '.workflows[] | "\(.name) state=\(.state)"'
gh workflow enable r.yml --repo niphr/cs
```

This bit the repo in 2026: the last commit was 2026-05-10 and the last scheduled
run was 2026-07-09, exactly 60 days later.

### Local Build
```bash
git checkout r-4.6.1
cd 1-rbase
./build.sh  # Sources ../env.sh for version settings
```

`env.sh` is not in the repository. Write it yourself before you run `build.sh`,
setting `R_VERSION`, `CRAN_CHECKPOINT_BINARY` and `CRAN_CHECKPOINT_SOURCE` to the
values in `.github/workflows/r.yml`.

## Architecture Notes

### Image Design
**rbase**: Full R environment with 100+ packages, TinyTeX, Quarto, Airflow, database drivers.

An `rworkbench` image added the Posit Workbench IDE on top of `rbase`. Commit
`18f36f5` removed the `2-rworkbench` folder and the workflow no longer builds it.
`content/install_posit.sh` stays in the `rbase` image for a later reinstatement.

### CS9 Task Execution Pattern
Tasks are run via the cs9 framework:
```r
PACKAGE::global$ss$run_task('TASK_NAME')
```

Task runner scripts in the image at `/usr/local/bin/`:
- `install_ss_and_run_task.sh` - Docker container version
- `install_ss_and_run_task_k8s.sh` - Kubernetes version

### GitHub-Integrated Packages
Installed via devtools with GITHUB_PAT. All are public today, so the workflow's
`secrets.GITHUB_TOKEN` is enough:
- `niphr/csdb`, `niphr/cstidy`, `niphr/cstime`, `niphr/csstyle`, `niphr/cs9`, `niphr/cs9example`
- `papadopoulos-lab/swereg`
- `niphr/norsyss`

**`secrets.GITHUB_TOKEN` is scoped to `niphr/cs` and cannot read a private repo
in another org.** If one of these packages goes private, the build fails with
HTTP 404 and needs a fine-grained PAT stored as a repo secret. This happened on
2026-05-12: norsyss moved to `niphr/norsyss`, a new private repo took the old
name `norsyss/norsyss`, and the GitHub rename redirect stopped working.

### Package Notes
- `pryr` was replaced with `lobstr` — `pryr` is not available for R >= 4.5.1

### Container User Model
- Runs as non-root `airflow` user (UID 50000) for Kubernetes compliance
- AIRFLOW_HOME set to ephemeral `/tmp/airflow` for horizontal scaling
