#!/bin/bash

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function clean {
    cd ${SCRIPT_DIR}/..
    rm -rf ${TO_SYNC}
}

function update_odoo {
    if [ ! -d ${SCRIPT_DIR}/../../odoo ]; then
        cd ${SCRIPT_DIR}/../..
        git clone -b 10.0 https://github.com/odoo/odoo
    fi
    cd ${SCRIPT_DIR}/../../odoo
    git fetch --all --prune
    git checkout 10.0
    git rebase
    git clean -fdx
    export LAST_COMMIT=$(git rev-parse HEAD)
}

function update_koozic {
    cd ${SCRIPT_DIR}/../../odoo
    cp -r $TO_SYNC ../koozic
    cd ${SCRIPT_DIR}/..
    mv decimal_precision web* addons/

    # Copy logo
    cd ${SCRIPT_DIR}
    cp img/nologo.png ../addons/web/static/src/img/
    cp img/logo.png ../addons/web/static/src/img/
    cp img/logo.png ../odoo/addons/base/static/img/main_partner-image.png

    # Commit new version
    cd ${SCRIPT_DIR}/..
    git add --all .
    git commit -m "Odoo up to https://github.com/odoo/odoo/commit/${LAST_COMMIT}"
}

cd ${SCRIPT_DIR}
export TO_SYNC=$(cat to_sync)

clean
update_odoo
update_koozic

exit $?
