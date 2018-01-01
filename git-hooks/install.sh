#!/bin/sh
set -e
cd "$(dirname "$(realpath $0)")"

find . -type f -not -name '*.sh' \
        | xargs -n 1 realpath \
        | xargs ln -s -f -t ../.git/hooks/
