# CS

Docker images for running R with the CS9 framework.

## Images

Two images are built nightly:

- `rbase` - R with 100+ packages, TinyTeX, Quarto, and Airflow
- `rworkbench` - adds Posit Workbench on top of rbase

## Usage

```bash
docker pull ghcr.io/niphr/cs/rbase:4.5.1
docker pull ghcr.io/niphr/cs/rworkbench:4.5.1
```

## Branches

- `main` has the CI/CD workflow
- `r-X.Y.Z` branches have the Dockerfiles for each R version
