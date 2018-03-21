#!/bin/bash
set -eo pipefail
shopt -s nullglob

service mysqld start
/etc/init.d/redis13 start
/etc/init.d/redis2 start

/bin/bash
