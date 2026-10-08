#!/usr/bin/env bash
# Test double: never reads or changes desktop configuration.
set -eu
palette=''
accent=''
mode=''
while (($#)); do
    case "$1" in
        --type) palette="$2"; shift 2 ;;
        --mode) mode="$2"; shift 2 ;;
        --color) accent="$2"; shift 2 ;;
        --noswitch) shift ;;
        *) exit 2 ;;
    esac
done
[[ "$mode" == 'dark' || "$mode" == 'light' ]]
[[ "$accent" == 'clear' || "$accent" =~ ^#[a-fA-F0-9]{6}$ ]]
sleep 0.2
[[ "$palette" != 'scheme-rainbow' ]]
