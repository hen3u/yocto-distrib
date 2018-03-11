#! /bin/bash

export LOCAL_REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

./combo-layer --conf combo-layer.conf init
./combo-layer --conf combo-layer.conf -n pull

exit 0
