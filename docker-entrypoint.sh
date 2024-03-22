#!/bin/sh

set -e

# Run init script
[ -e $WEBHOOK_INIT_SCRIPT ] && $WEBHOOK_INIT_SCRIPT

/usr/local/bin/webhook $@
