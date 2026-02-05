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
├── 1-rbase/
│   ├── Dockerfile            # Base R image definition
│   ├── build.sh              # Local build script
│   └── content/              # Scripts copied into image
└── 2-rworkbench/
    ├── Dockerfile            # IDE layer on top of rbase
    ├── conf/                 # Server configuration
    └── content/              # Startup scripts
```

## Build Commands

### CI/CD Build (GitHub Actions)
Images are built via `.github/workflows/r.yml`:
- Triggered daily at 15:00 UTC or manually via workflow_dispatch
- Pushes to `ghcr.io/niphr/cs/rbase:X.Y.Z` and `ghcr.io/niphr/cs/rworkbench:X.Y.Z`

### Local Build
```bash
git checkout r-4.5.1
cd 1-rbase
./build.sh  # Sources ../env.sh for version settings
```

## Architecture Notes

### Two-Stage Image Design
1. **rbase**: Full R environment with 100+ packages, TinyTeX, Quarto, Airflow, database drivers
2. **rworkbench**: Adds Posit Workbench IDE on top of rbase

### CS9 Task Execution Pattern
Tasks are run via the cs9 framework:
```r
PACKAGE::global$ss$run_task('TASK_NAME')
```

Task runner scripts in the image at `/usr/local/bin/`:
- `install_ss_and_run_task.sh` - Docker container version
- `install_ss_and_run_task_k8s.sh` - Kubernetes version

### GitHub-Integrated Packages
Private packages installed via devtools with GITHUB_PAT:
- `csids/csstyle`, `csids/cs9`, `csids/cs9example`
- `papadopoulos-lab/swereg`
- `norsyss/norsyss`

### Container User Model
- Runs as non-root `airflow` user (UID 50000) for Kubernetes compliance
- AIRFLOW_HOME set to ephemeral `/tmp/airflow` for horizontal scaling
