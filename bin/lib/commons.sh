#!/bin/bash
## =========================================================================
#   Script to setup shell and to define commonly used functions.
## =========================================================================
# shellcheck disable=SC1090 # "Can't follow non-constant source."

# exit if local config is already loaded ('DEPLOY_MODE' is defined in config)
test ! -z "${DEPLOY_MODE}" && return

# Get ROOT directory from parent script or calculate relative.
export DIR_ROOT=${DIR_ROOT:-$(cd "$(dirname "$0")/../../" && pwd)}
# file name for local configuration
export FILE_CFG="${DIR_ROOT}/cfg.local.sh"
# available deployment modes: development & production
export DEPLOY_MODE_DEV="dev"
export DEPLOY_MODE_PROD="prod"

## *************************************************
#   Define commonly used functions:
#     - info()
#     - err()
#   and this context functions:
#     - trap()
## *************************************************

##
# Print out info message & error message with timestamp
##
# Get the name of the parent script (exclude all up to '/' from '$0')
export SCRIPT_NAME=${SCRIPT_NAME:-${0##*/}}
info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] (${SCRIPT_NAME}) INFO: $*"
}
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] ($SCRIPT_NAME) ERROR: $*" >&2
}

##
# Trap exit & errors signals
##
finish() {
  # use first parameter of `finish` or exit status of the last executed command as `EXIT_STATUS`
  local EXIT_STATUS="${1:-$?}"
  # print out error message if exit status is not clean (!=0)
  if test "${EXIT_STATUS} -nq 0"; then
    err "exit code: '${EXIT_STATUS}'"
  fi
  # exit from execution with given status
  exit "${EXIT_STATUS}"
}

## *************************************************
#   This script activities.
## *************************************************
# load local config or exit with error
if test -f "${FILE_CFG}"; then
  . "${FILE_CFG}"
  info "Local configuration is loaded from '${FILE_CFG}'."
else
  err "There is no expected configuration in '${FILE_CFG}'. Aborting..."
  exit 255
fi

##
# Setup shell
##
# Print commands and their arguments as they are executed.
test -n "${DEBUG_MODE}" && set -x
# Exit immediately if a command exits with a non-zero status.
#  the return value of a pipeline is the status of the last command to exit with a non-zero status,
#  or zero if no command exited with a non-zero status
test -n "${FAILSAFE_MODE}" && set -e -o pipefail
test -n "${FAILSAFE_MODE}" && trap finish SIGHUP SIGINT SIGQUIT SIGTERM ERR
