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

## Where the R packages come from

Three sources, and they differ in whether the version is pinned.

| Source | Packages | Pinned |
|---|---|---|
| CRAN checkpoint | About 200, listed in `install2.r` | Yes, to a dated snapshot |
| niphr r-universe | The ten cs\* packages | **No** |
| GitHub | `norsyss`, `swereg` | No |

`CRAN_CHECKPOINT_BINARY` and `CRAN_CHECKPOINT_SOURCE` in
`.github/workflows/r.yml` set the snapshot date for the CRAN packages.

The ten cs\* packages come from <https://niphr.r-universe.dev> as prebuilt Linux
binaries: `csalert`, `csdata`, `csdb`, `csmaps`, `csstyle`, `cstidy`, `cstime`,
`csutil`, `cs9` and `cs9example`. They install in about 9 seconds with no
compilation.

The r-universe serves head of main and keeps only the newest build. It has no
equivalent of a dated checkpoint, so **the cs\* versions are not reproducible
across rebuilds**. Two builds of the same commit on different days can produce
different cs\* code. This is deliberate. These are our own packages and we want
the newest.

Before 2026-08-13 the cs\* packages came from a mix of the CRAN checkpoint and
`install_github`. Four of them had no `install_github` line, so they silently
took whatever CRAN held. `csutil` was three years behind at 2023.4.25, and
nothing in the build reported it.

## Branches

- `main` has the CI/CD workflow
- `r-X.Y.Z` branches have the Dockerfiles for each R version
