#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

script_dir="$(dirname "${BASH_SOURCE[0]}")"
script_name="$(basename "${BASH_SOURCE[0]}")"

tmp_dir="$(mktemp -d)"
tmp_dir_dsn="${tmp_dir}/design"
tmp_dir_mfg="${tmp_dir}/manufacturing"
tmp_dir_asb="${tmp_dir}/assembly"
out_dir='./build'

kicad_expected_version='9.0.4'
kicad_project_name='MitsubishiSC'
kicad_sch_file="./hardware/${kicad_project_name}.kicad_sch"
kicad_pcb_file="./hardware/${kicad_project_name}.kicad_pcb"

build_commit="$(git rev-parse --verify HEAD)"
build_timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

function cleanup() {
    printf "cleaning up working directories\n"
    rm -rf "${tmp_dir}"
}

# Ensure KiCad CLI is installed and matches expected version
if ! command -v kicad-cli &> /dev/null; then
    printf "error: KiCad CLI not found\n" >&2
    exit 1
fi
kicad_actual_version="$(kicad-cli version)"
if [[ "${kicad_actual_version}" != "${kicad_expected_version}" ]]; then
    printf "error: KiCad CLI version does not match expected version %s: got %s\n" "${kicad_expected_version}" "${kicad_actual_version}" >&2
    exit 1
fi

trap cleanup SIGHUP SIGINT SIGTERM ERR EXIT

# Ensure required file directories are created
mkdir -p "${tmp_dir}"
mkdir -p "${tmp_dir_dsn}"
mkdir -p "${tmp_dir_mfg}"
mkdir -p "${tmp_dir_asb}"
mkdir -p "${out_dir}"

# NOTE: Configuration based on JLCPCB requirements for KiCad 8
# https://jlcpcb.com/help/article/how-to-generate-gerber-and-drill-files-in-kicad-8
printf "Exporting Gerber files...\n"
kicad-cli pcb export gerbers \
    --layers F.Cu,In1.Cu,In2.Cu,In3.Cu,In4.Cu,B.Cu,F.Paste,B.Paste,F.Silkscreen,B.Silkscreen,F.Mask,B.Mask,Edge.Cuts \
    --no-x2 \
    --no-netlist \
    --subtract-soldermask \
    --use-drill-file-origin \
    --output "${tmp_dir_mfg}" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    "${kicad_pcb_file}"

# NOTE: Configuration based on JLCPCB requirements for KiCad 8
# https://jlcpcb.com/help/article/how-to-generate-gerber-and-drill-files-in-kicad-8
printf "Exporting drill and drill map files...\n"
kicad-cli pcb export drill \
    --excellon-separate-th \
    --drill-origin plot \
    --generate-map \
    --map-format gerberx2 \
    --output "${tmp_dir_mfg}/" \
    "${kicad_pcb_file}"

printf "Exporting BOM files...\n"
kicad-cli sch export bom \
    --output "${tmp_dir_asb}/${kicad_project_name}-BOM.csv" \
    --fields 'Reference,Value,Footprint,Manufacturer,Manufacturer Part Number,Distributor,Distributor Part Number,${QUANTITY},Comment,${DNP}' \
    --labels 'Reference,Value,Footprint,Manufacturer,Manufacturer Part Number,Distributor,Distributor Part Number,Quantity,Comment,DNP' \
    --exclude-dnp \
    "${kicad_sch_file}"
kicad-cli sch export bom \
    --output "${tmp_dir_asb}/${kicad_project_name}-BOM-Grouped.csv" \
    --fields 'Reference,Value,Footprint,Manufacturer,Manufacturer Part Number,Distributor,Distributor Part Number,${QUANTITY},Comment,${DNP}' \
    --labels 'Reference,Value,Footprint,Manufacturer,Manufacturer Part Number,Distributor,Distributor Part Number,Quantity,Comment,DNP' \
    --group-by 'Value' \
    --exclude-dnp \
    "${kicad_sch_file}"

printf "Exporting component placement files...\n"
kicad-cli pcb export pos \
    --output "${tmp_dir_asb}/${kicad_project_name}-CPL.csv" \
    --format csv \
    --side both \
    --units mm \
    --use-drill-file-origin \
    --exclude-dnp \
    "${kicad_pcb_file}"
kicad-cli pcb export pos \
    --output "${tmp_dir_asb}/${kicad_project_name}-CPL.txt" \
    --format ascii \
    --side both \
    --units mm \
    --use-drill-file-origin \
    --exclude-dnp \
    "${kicad_pcb_file}"

printf "Exporting schematic file...\n"
kicad-cli sch export pdf \
    --output "${tmp_dir_dsn}/${kicad_project_name}.pdf" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    "${kicad_sch_file}"

printf "Exporting 3D model files...\n"
# FIXME: Re-enable STEP export after regenerated footprints are released
# https://gitlab.com/kicad/libraries/kicad-footprint-generator/-/issues/728
# kicad-cli pcb export step \
#     --output "${tmp_dir_dsn}/${kicad_project_name}.step" \
#     --user-origin 0,0 \
#     --subst-models \
#     "${kicad_pcb_file}"
kicad-cli pcb export vrml \
    --output "${tmp_dir_dsn}/${kicad_project_name}.wrl" \
    --user-origin 0,0 \
    "${kicad_pcb_file}"

# FIXME: Due to issue parsing negative values, we deliberately
# add an extra space in the arg value of `--rotate` as workaround.
# https://gitlab.com/kicad/code/kicad/-/issues/20191
printf "Exporting 3D render files...\n"
kicad-cli pcb render \
    --output "${tmp_dir_dsn}/${kicad_project_name}-Top.png" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    --zoom '0.8' \
    --side top \
    "${kicad_pcb_file}"
kicad-cli pcb render \
    --output "${tmp_dir_dsn}/${kicad_project_name}-TopIso.png" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    --zoom '0.8' \
    --side top \
    --rotate ' -45,0,45' \
    "${kicad_pcb_file}"
kicad-cli pcb render \
    --output "${tmp_dir_dsn}/${kicad_project_name}-Bottom.png" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    --zoom '0.8' \
    --side bottom \
    "${kicad_pcb_file}"
kicad-cli pcb render \
    --output "${tmp_dir_dsn}/${kicad_project_name}-BottomIso.png" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    --zoom '0.8' \
    --side bottom \
    --rotate ' -45,0,45' \
    "${kicad_pcb_file}"

cp -R "${tmp_dir_dsn}" "${out_dir}"
cp -R "${tmp_dir_mfg}" "${out_dir}"
cp -R "${tmp_dir_asb}" "${out_dir}"
