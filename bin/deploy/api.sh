#!/bin/bash
## =========================================================================
#   Deploy 'vue-storefront-api' application for the project.
## =========================================================================
# shellcheck disable=SC1090 # Can't follow non-constant source.
# root directory (set before or relative to the current shell script)
DIR_ROOT=${DIR_ROOT:=$(cd "$(dirname "$0")/../../" && pwd)}
# load local config and define common functions
. "${DIR_ROOT}/bin/lib/commons.sh"

## =========================================================================
#   Setup & validate working environment
## =========================================================================
# check external vars used in this script (see cfg.[work|live].sh)
: "${DEPLOY_MODE:?}"
: "${DEPLOY_MODE_DEV:?}"
: "${ES_API_VERSION:?}"
: "${ES_HOST:?}"
: "${ES_INDEX_NAME=:?}"
: "${ES_PORT:?}"
: "${REDIS_DB:?}"
: "${REDIS_HOST:?}"
: "${REDIS_PORT:?}"
: "${VSF_API_SERVER_IP:?}"
: "${VSF_API_SERVER_PORT:?}"
: "${VSF_API_WEB_HOST:?}"
: "${VSF_API_WEB_PROTOCOL:?}"
# local context vars
DIR_APPS="${DIR_ROOT}/apps"
DIR_VSF_API="${DIR_APPS}/vue-storefront-api"

# create applications root directory if not exist
test ! -d "${DIR_APPS}" && mkdir -p "${DIR_APPS}"
cd "${DIR_APPS}" || exit 255

info "========================================================================"
info "Clone 'vue-storefront-api' app."
info "========================================================================"
git clone https://github.com/DivanteLtd/vue-storefront-api.git "${DIR_VSF_API}"
cd "${DIR_VSF_API}" || exit 255
git checkout develop

info "========================================================================"
info "Create local config for 'vue-storefront-api' app."
info "========================================================================"
cat <<EOM | tee "${DIR_VSF_API}/config/local.json"
{
  "server": {
    "host": "${VSF_API_SERVER_IP}",
    "port": ${VSF_API_SERVER_PORT}
  },
  "elasticsearch": {
    "host": "${ES_HOST}",
    "port": ${ES_PORT},
    "indices": [
      "${ES_INDEX_NAME}"
    ],
    "apiVersion": "${ES_API_VERSION}"
  },
  "redis": {
    "host": "${REDIS_HOST}",
    "port": ${REDIS_PORT},
    "db": ${REDIS_DB}
  },
  "authHashSecret": "__SECRET_CHANGE_ME__",
  "objHashSecret": "__SECRET_CHANGE_ME__",
  "tax": {
    "defaultCountry": "RU"
  },
  "magento2": {},
  "magento1": {}
}
EOM

info "========================================================================"
info "Build 'vue-storefront-api' app in '${DEPLOY_MODE}' mode."
info "========================================================================"
# build app according to the deployment mode (default: production)
if test "${DEPLOY_MODE}" != "${DEPLOY_MODE_DEV}"; then
#  git checkout "v1.11.0"
  git checkout "master"

  yarn install
  yarn build
#  yarn start
  yarn db7 new
else
  info "deploy in dev mode"
fi

info "========================================================================"
info "'vue-storefront-api' app is deployed in '${DEPLOY_MODE}' mode."
info "========================================================================"
