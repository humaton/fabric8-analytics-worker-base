#!/bin/bash -ex

mercator /tmp

"${OWASP_DEP_CHECK_PATH}bin/dependency-check.sh" --version

"${SCANCODE_PATH}bin/scancode" --version
