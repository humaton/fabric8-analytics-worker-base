#!/bin/bash -ex

# Run basic sanity checks

worker_base_image=${WORKER_BASE_IMAGE:-registry.devshift.net/fabric8-analytics/f8a-worker-base:latest}
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
check_script="${here}/check.sh"

gc() {
    retval=$?
    echo "${container_name}" | xargs -r docker rm -vf || :
    [[ $retval -ne 0 ]] && echo "Test Failed."
    exit $retval
}
trap gc EXIT SIGINT

if [ "$REBUILD" == "1" ] || \
     !(docker inspect $worker_base_image > /dev/null 2>&1); then
  echo "Building $worker_base_image for testing"
  docker build --tag=$worker_base_image ..
fi

container_name=$(docker run -d -v ${check_script}:/check.sh:ro,Z ${worker_base_image} sleep 100)
echo "Worker-base container name is ${container_name}."

docker exec -t ${container_name} /check.sh

echo "Test Passed."

