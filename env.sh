#!/bin/bash

export R_VERSION=4.5.1

# setting snapshot to 2025-07-15 (decision taken on 2025-07-29)
export CRAN_CHECKPOINT_BINARY=https://packagemanager.posit.co/cran/__linux__/jammy/2025-07-15
export CRAN_CHECKPOINT_SOURCE=https://packagemanager.posit.co/cran/2025-07-15

# get checkpoint IDs here:
# https://packagemanager.rstudio.com/client/#/repos/1/overview
# click on any date
# below the date picker, see the generated URl - press "change" and choose FOCAL20 from the dropdown
# grab the number from the link
# place it into this file as the variable CRAN_CHECKPOINT