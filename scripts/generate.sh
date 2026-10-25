#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

script_dir="$(dirname "${BASH_SOURCE[0]}")"
script_name="$(basename "${BASH_SOURCE[0]}")"

esp-matter-mfg-tool \
    --vendor-id '0xFFF2' \
    --vendor-name 'Mitsubishi Electric' \
    --product-id '0x8001' \
    --product-name 'MSXY-FP10VG' \
    --serial-num "$(openssl rand -hex 8)" \
    --mfg-date "$(date -u +'%Y%m%d')" \
    --enable-rotating-device-id \
    --rd-id-uid "$(openssl rand -hex 16)" \
    --pai \
    --key "${script_dir}/Chip-Test-PAI-FFF2-8001-Key.pem" \
    --cert "${script_dir}/Chip-Test-PAI-FFF2-8001-Cert.pem" \
    --cert-dclrn "${script_dir}/Chip-Test-CD-FFF2-8001.der"
