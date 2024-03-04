#!/usr/bin/env bash

echo $1

docker run --rm \
    -v $(pwd)/test/$1/hooks.json:/etc/webhook/hooks.json \
    -v $(pwd)/test/$1/nomad:/var/nomad \
    -p 9000:9000 \
    alpha-prime-webhook:0.1.0 \
        -hooks=/etc/webhook/hooks.json \
        -hotreload \
        -verbose
