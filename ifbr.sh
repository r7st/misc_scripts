#!/usr/bin/env bash
# `ip -br a`-like macos ifconfig output. ignores ipv6

ifconfig | awk '\
(match($0,/^[a-z0-9]+:/)>0){ IFace=substr($0,RSTART,RLENGTH-1) }
(match($0,/inet [0-9.]+/)>0){ IP4=substr($0,RSTART+5,RLENGTH-5) }
(match($0,/netmask 0x[a-z0-9]{8}/)>0){ NM=substr($0,RSTART+8,RLENGTH-8) }
(length(IP4)>0){ printf("%-8s %-16s/nm %s\n",IFace,IP4,NM); IP4="" }
'
