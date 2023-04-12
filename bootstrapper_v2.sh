#!/bin/ash

set -euo pipefail
cd /tmp
tar -xzf /tmp/payload.tar.gz
chmod a+x /tmp/script.sh
/tmp/script.sh exploit

exit 0