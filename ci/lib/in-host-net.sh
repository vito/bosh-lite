#!/usr/bin/env bash

set -e -x

mkdir -p /var/run/netns

ln -sf /proc/1/ns/net /var/run/netns/default

ip netns exec default "$@"
