#!/bin/bash
# Author: 9cco
# Date: 2025-12-23
# Use: Attempts to find the external IP of the system and saves it to a file.

outFilePath="$HOME/.config/external-ip.txt"

IPv4_regex='([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])'

ip=$(curl -s -4 https://cloudflare.com/cdn-cgi/trace | grep -E '^ip'); ret=$?
if [[ ! $ret == 0 ]]; then # In the case that cloudflare failed to return an ip.
    # Attempt to get the ip from other websites.
    ip=$(curl -s https://api.ipify.org || curl -s https://ipv4.icanhazip.com)
else
    # Extract just the ip from the ip line from cloudflare.
    ip=$(echo $ip | sed -E "s/^ip=($IPv4_regex)$/\1/")
fi

# Use regex to check for proper IPv4 format.
if [[ $ip =~ $IPv4_regex ]]; then
    echo $ip > $outFilePath
    exit 0
fi

ipv6=$(curl -s -6 https://cloudflare.com/cdn-cgi/trace | grep -E '^ip' | cut --delimiter='=' -f2 | xargs); ret=$?
if [[ ! $ret == 0 ]]; then # In the case that cloudflare failed to return an ipv6
    ipv6=$(curl -s https://api64.ipify.org)
fi

# Use regex to check for proper IPv6 format and save to file
IPv6_regex='[a-fA-F0-9:]{,39}'
if [[ $ipv6 =~ $IPv6_regex ]]; then
    echo $ipv6 > $outFilePath
    exit 0
fi

logger -s "update-ip.sh: Failed to find either a valid IPv6 or IPv4"
exit 2
