#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

failed=0

blocked_path_regex='(^|/)([.]env|secrets[.]yaml|secret[.]yaml|password_file|coordinator_backup[.]json|database[.]db|state[.]json)(/|$)|(^|/)home-assistant_v2[.]db($|-)|^zigbee2mqtt/data/configuration[.]yaml

if git ls-files | grep -E -- "$blocked_path_regex"; then
  echo "ERROR: a runtime secret or state file is tracked."
  failed=1
fi

mapfile -t content_files < <(
  git ls-files |
    grep -v '^scripts/sanitize-check[.]sh$' |
    grep -vE '[.](png|jpe?g|gif|webp|ico|mp4|zip|gz)$'
)

patterns=(
  '192[.]168[.][0-9]{1,3}[.][0-9]{1,3}'
  '(^|[^0-9])10[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}([^0-9]|$)'
  '172[.](1[6-9]|2[0-9]|3[01])[.][0-9]{1,3}[.][0-9]{1,3}'
  '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}'
  'USB_Dongle_Plus_[[:xdigit:]]{4,}-if'
  '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'
  'gh[pousr]_[A-Za-z0-9_]{20,}'
  'AKIA[0-9A-Z]{16}'
)

for pattern in "${patterns[@]}"; do
  if (("${#content_files[@]}" > 0)) &&
     grep -nIE -- "$pattern" "${content_files[@]}"; then
    echo "ERROR: possible private infrastructure data or credential detected."
    failed=1
  fi
done

if ((failed != 0)); then
  exit 1
fi

echo "Sanitization check passed."


if git ls-files | grep -E -- "$blocked_path_regex"; then
  echo "ERROR: a runtime secret or state file is tracked."
  failed=1
fi

mapfile -t content_files < <(
  git ls-files |
    grep -v '^scripts/sanitize-check[.]sh$' |
    grep -vE '[.](png|jpe?g|gif|webp|ico|mp4|zip|gz)$'
)

patterns=(
  '192[.]168[.][0-9]{1,3}[.][0-9]{1,3}'
  '(^|[^0-9])10[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}([^0-9]|$)'
  '172[.](1[6-9]|2[0-9]|3[01])[.][0-9]{1,3}[.][0-9]{1,3}'
  '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}'
  'USB_Dongle_Plus_[[:xdigit:]]{4,}-if'
  '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'
  'gh[pousr]_[A-Za-z0-9_]{20,}'
  'AKIA[0-9A-Z]{16}'
)

for pattern in "${patterns[@]}"; do
  if (("${#content_files[@]}" > 0)) &&
     grep -nIE -- "$pattern" "${content_files[@]}"; then
    echo "ERROR: possible private infrastructure data or credential detected."
    failed=1
  fi
done

if ((failed != 0)); then
  exit 1
fi

echo "Sanitization check passed."
