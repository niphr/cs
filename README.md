# CS

Docker images for running R with the CS9 framework.

## Images

One image is built nightly:

- `rbase` - R with 100+ packages, TinyTeX, Quarto, and Airflow

An `rworkbench` image that added Posit Workbench on top of `rbase` was built
until commit `18f36f5` removed the `2-rworkbench` folder. The workflow no longer
builds it.

## Usage

```bash
docker pull ghcr.io/niphr/cs/rbase:4.6.1
```

## Branches

- `main` has the CI/CD workflow
- `r-X.Y.Z` branches have the Dockerfiles for each R version
