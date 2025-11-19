#!/bin/bash
source ../env.sh

if hash buildah 2>/dev/null; then
    IMGBUILDER='sudo buildah bud'
    IMG='sudo buildah'
else
    IMGBUILDER='docker build'
    IMG='docker'
fi

$IMGBUILDER \
  --pull \
  --squash \
  --tag=localhost/cs9-su-rbase:$R_VERSION \
  --build-arg R_VERSION=$R_VERSION \
  --build-arg CRAN_CHECKPOINT_BINARY=$CRAN_CHECKPOINT_BINARY \
  --build-arg CRAN_CHECKPOINT_SOURCE=$CRAN_CHECKPOINT_SOURCE \
  .

$IMG image prune -f
