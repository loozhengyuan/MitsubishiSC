#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

script_dir="$(dirname "${BASH_SOURCE[0]}")"
script_name="$(basename "${BASH_SOURCE[0]}")"

tmp_dir="$(mktemp -d)"
out_dir='./build/hardware'

kicad_expected_version='10.0.7'
kicad_project_name='MitsubishiSC'
kicad_sch_file="./hardware/${kicad_project_name}.kicad_sch"
kicad_pcb_file="./hardware/${kicad_project_name}.kicad_pcb"

build_version="$(< ./VERSION)"
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

# Ensure version is valid semver and derive board version (i.e. MAJOR.MINOR)
if [[ ! "${build_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    printf "error: VERSION is not a valid X.Y.Z version: got %s\n" "${build_version}" >&2
    exit 1
fi
board_version="${build_version%.*}"

# NOTE: Release asset naming convention is `<project>-v<version>-hw-<content>.<ext>`
asset_prefix="${kicad_project_name}-v${build_version}-hw"

trap cleanup SIGHUP SIGINT SIGTERM ERR EXIT

# Ensure required file directories are created
# NOTE: The output directory is cleared to avoid releasing stale assets (e.g.
# from a different version) left over from a previous run.
rm -rf "${out_dir}"
mkdir -p "${tmp_dir}"
mkdir -p "${out_dir}"

# NOTE: Configuration based on JLCPCB requirements for KiCad 8
# https://jlcpcb.com/help/article/how-to-generate-gerber-and-drill-files-in-kicad-8
printf "Exporting Gerber files...\n"
kicad-cli pcb export gerbers \
    --layers '*.Cu,*.Paste,*.Silkscreen,*.Mask,Edge.Cuts' \
    --no-x2 \
    --no-netlist \
    --subtract-soldermask \
    --use-drill-file-origin \
    --output "${tmp_dir}" \
    --define-var "BOARD_VERSION=${board_version}" \
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
    --output "${tmp_dir}/" \
    "${kicad_pcb_file}"

# NOTE: Fab houses expect a single flat archive of Gerber and drill files.
# Python is used as `zip` is not guaranteed to be available in the KiCad image.
printf "Archiving Gerber and drill files...\n"
python3 -m zipfile -c "${out_dir}/${asset_prefix}-gerbers.zip" "${tmp_dir}"/*

printf "Exporting IPC-2581 file...\n"
kicad-cli pcb export ipc2581 \
    --output "${out_dir}/${asset_prefix}-ipc2581.xml" \
    --define-var "BOARD_VERSION=${board_version}" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    --bom-col-mfg 'Manufacturer' \
    --bom-col-mfg-pn 'Manufacturer Part Number' \
    --bom-col-dist 'Distributor' \
    --bom-col-dist-pn 'Distributor Part Number' \
    "${kicad_pcb_file}"

# NOTE: The default BOM has one row per value, which is what CMs quote from,
# while the per-designator BOM has one row per reference designator.
printf "Exporting BOM files...\n"
kicad-cli sch export bom \
    --output "${out_dir}/${asset_prefix}-bom.csv" \
    --fields 'Reference,Value,Footprint,Manufacturer,Manufacturer Part Number,Distributor,Distributor Part Number,${QUANTITY},Comment,${DNP}' \
    --labels 'Reference,Value,Footprint,Manufacturer,Manufacturer Part Number,Distributor,Distributor Part Number,Quantity,Comment,DNP' \
    --group-by 'Value' \
    --exclude-dnp \
    "${kicad_sch_file}"
kicad-cli sch export bom \
    --output "${out_dir}/${asset_prefix}-bom-per-designator.csv" \
    --fields 'Reference,Value,Footprint,Manufacturer,Manufacturer Part Number,Distributor,Distributor Part Number,${QUANTITY},Comment,${DNP}' \
    --labels 'Reference,Value,Footprint,Manufacturer,Manufacturer Part Number,Distributor,Distributor Part Number,Quantity,Comment,DNP' \
    --exclude-dnp \
    "${kicad_sch_file}"

printf "Exporting component placement files...\n"
kicad-cli pcb export pos \
    --output "${out_dir}/${asset_prefix}-placement.csv" \
    --format csv \
    --side both \
    --units mm \
    --use-drill-file-origin \
    --exclude-dnp \
    "${kicad_pcb_file}"
# Create a modified placement CSV with headers matching JLCPCB requirements
sed '1s/.*/Designator,Val,Package,Mid X,Mid Y,Rotation,Layer/' "${out_dir}/${asset_prefix}-placement.csv" > "${out_dir}/${asset_prefix}-placement-jlcpcb.csv"

printf "Exporting assembly drawing files...\n"
kicad-cli pcb export pdf \
    --output "${out_dir}/${asset_prefix}-assembly-top.pdf" \
    --define-var "BOARD_VERSION=${board_version}" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    --layers 'F.Fab,Edge.Cuts' \
    --black-and-white \
    --include-border-title \
    --exclude-value \
    --sketch-pads-on-fab-layers \
    --crossout-DNP-footprints-on-fab-layers \
    "${kicad_pcb_file}"
kicad-cli pcb export pdf \
    --output "${out_dir}/${asset_prefix}-assembly-bottom.pdf" \
    --define-var "BOARD_VERSION=${board_version}" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    --layers 'B.Fab,Edge.Cuts' \
    --black-and-white \
    --include-border-title \
    --exclude-value \
    --sketch-pads-on-fab-layers \
    --crossout-DNP-footprints-on-fab-layers \
    --mirror \
    "${kicad_pcb_file}"

printf "Exporting schematic file...\n"
kicad-cli sch export pdf \
    --output "${out_dir}/${asset_prefix}-schematic.pdf" \
    --define-var "BOARD_VERSION=${board_version}" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    "${kicad_sch_file}"

printf "Exporting 3D model files...\n"
kicad-cli pcb export step \
    --output "${out_dir}/${asset_prefix}-3d.step" \
    --user-origin 0,0 \
    --subst-models \
    "${kicad_pcb_file}"

printf "Exporting 3D render files...\n"
kicad-cli pcb render \
    --output "${out_dir}/${asset_prefix}-render-top.png" \
    --define-var "BOARD_VERSION=${board_version}" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    --zoom '0.8' \
    --side top \
    "${kicad_pcb_file}"
kicad-cli pcb render \
    --output "${out_dir}/${asset_prefix}-render-top-iso.png" \
    --define-var "BOARD_VERSION=${board_version}" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    --zoom '0.8' \
    --side top \
    --rotate '-45,0,45' \
    "${kicad_pcb_file}"
kicad-cli pcb render \
    --output "${out_dir}/${asset_prefix}-render-bottom.png" \
    --define-var "BOARD_VERSION=${board_version}" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    --zoom '0.8' \
    --side bottom \
    "${kicad_pcb_file}"
kicad-cli pcb render \
    --output "${out_dir}/${asset_prefix}-render-bottom-iso.png" \
    --define-var "BOARD_VERSION=${board_version}" \
    --define-var "BUILD_COMMIT=${build_commit}" \
    --define-var "BUILD_TIMESTAMP=${build_timestamp}" \
    --zoom '0.8' \
    --side bottom \
    --rotate '-45,0,45' \
    "${kicad_pcb_file}"

