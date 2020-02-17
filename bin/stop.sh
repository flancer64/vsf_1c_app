#!/bin/bash
## =========================================================================
#   Stop all VSF apps (front & API).
## =========================================================================
# shellcheck disable=SC1090 # Can't follow non-constant source.
# root directory (set before or relative to the current shell script)
DIR_ROOT=${DIR_ROOT:=$(cd "$(dirname "$0")/../" && pwd)}
# replace SCRIPT_NAME to use in outbut logs
SCRIPT_NAME=${BASH_SOURCE##*/} && export SCRIPT_NAME
# load local config and define common functions
. "${DIR_ROOT}/bin/lib/commons.sh"

## =========================================================================
#   Setup & validate working environment
## =========================================================================
# check external vars used in this script (see cfg.[work|live].sh)
: "${DEPLOY_MODE:?}"
# local context vars
DIR_PID="${DIR_ROOT}/var/pid"

info "========================================================================"
info "Stop VSF front app."
info "========================================================================"
PID_FRONT=$(<"${DIR_PID}/front.pid")
kill -s SIGTERM "${PID_FRONT}"
info "========================================================================"
info "VSF front app is stopped (PID=${PID_FRONT})."
info "========================================================================"

info "========================================================================"
info "Stop VSF API app."
info "========================================================================"
PID_API=$(<"${DIR_PID}/api.pid")
kill -s SIGTERM "${PID_API}"
info "========================================================================"
info "VSF API app is stopped (PID=${PID_API})."
info "========================================================================"

info "========================================================================"
info "Stop VSF O2M app."
info "========================================================================"
PID_O2M=$(<"${DIR_PID}/o2m.pid")
kill -s SIGTERM "${PID_O2M}"
info "========================================================================"
info "VSF O2M app is stopped (PID=${PID_O2M})."
info "========================================================================"
