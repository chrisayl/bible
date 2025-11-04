#!/usr/bin/env bash
# Common helper functions for DevContainer scripts

log() {
  echo -e "\033[1;34m[INFO]\033[0m $1"
}

error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
  exit 1
}
