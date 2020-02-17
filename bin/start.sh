#!/bin/bash
## =========================================================================
#   Start all VSF apps (front & API).
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
DIR_APPS="${DIR_ROOT}/apps"
DIR_LOG="${DIR_ROOT}/var/log"
DIR_PID="${DIR_ROOT}/var/pid"
DIR_FRONT="${DIR_APPS}/vue-storefront"
DIR_API="${DIR_APPS}/vue-storefront-api"
export NODE_TLS_REJECT_UNAUTHORIZED="0" # disable "self-signed cert" error

info "========================================================================"
info "Start VSF front app."
info "========================================================================"

cd "${DIR_FRONT}" || exit 255
./node_modules/.bin/ts-node -P ./tsconfig-build.json ./core/scripts/server.ts >>"${DIR_LOG}/front.log" 2>&1 &
# if return value ($?) is "0" then save PID ($!) into the file
PID_FRONT="${!}"
test "${?}" -eq 0 && echo "${PID_FRONT}" >"${DIR_PID}/front.pid"

info "========================================================================"
info "VSF front app is started (PID=${PID_FRONT})."
info "========================================================================"

info "========================================================================"
info "Start VSF API app."
info "========================================================================"

cd "${DIR_API}" || exit 255
node ./dist/index.js >>"${DIR_LOG}/api.log" 2>&1 &
# if return value ($?) is "0" then save PID ($!) into the file
PID_API="${!}"
test "${?}" -eq 0 && echo "${PID_API}" >"${DIR_PID}/api.pid"

info "========================================================================"
info "VSF API app is started (PID=${PID_API})."
info "========================================================================"

info "========================================================================"
info "Start VSF O2M (Orders to Magento) app."
info "========================================================================"

cd "${DIR_API}" || exit 255
node ./dist/worker/order_to_magento2.js start >>"${DIR_LOG}/o2m.log" 2>&1 &
# if return value ($?) is "0" then save PID ($!) into the file
PID_O2M="${!}"
test "${?}" -eq 0 && echo "${PID_O2M}" >"${DIR_PID}/o2m.pid"

info "========================================================================"
info "VSF O2M app is started (PID=${PID_O2M})."
info "========================================================================"
