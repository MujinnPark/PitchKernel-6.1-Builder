#!/usr/bin/env bash
# ======================================================
# Minimal KernelSU-Next + SUSFS driver for malachite/PitchKernel
# ======================================================
# This is NOT Luminaire's full build.sh — it's a thin driver that sources
# Luminaire's real, verified ksunext.sh and susfs.sh scripts (originally
# from chainonyourdoor/LuminaireProtocol, vendored here under
# vendor/pitchkernel/kernel/android14-6.1-lts/ksu/) with the same env vars
# those scripts expect. No addon system, no checkpoint engine, no other
# root solutions (SukiSU/ReSukiSU) — just the KSU-Next+SUSFS path.
#
# Pinned commits below come from Luminaire's own manifest.json
# (kernel/android14-6.1-lts/manifest.json), which are the combos their
# checkpoint system verified actually build — not guesses.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export ROOT_DIR
source "${ROOT_DIR}/functions.sh"

# --- required env vars these scripts read ---
export KERNEL_SRC="${1:?Usage: apply_ksu_susfs.sh <path-to-kernel-source>}"
export LUMINAIRE_PATCH_DIR="${ROOT_DIR}"
export KERNEL_VARIANT="KSUNEXT"
export SUSFS_ENABLED="true"

# Pinned refs from Luminaire's manifest.json (android14-6.1-lts).
# These are the exact commits their checkpoint system verified as "good" —
# update only after testing a newer combo yourself.
export KSUNEXT_SUSFS_FORK_REF="26fded805206ae4542f4745e09cc465412994492"
export SUSFS_KSUNEXT_REF="ee71ca33d08710d686f2bdba27cacefe9e615fb9"

# SUBLEVEL is needed by susfs.sh's namespace.c pre-patch logic (kernels at
# sublevel >= 157 need the blk.h include temporarily removed/restored).
export SUBLEVEL="$(grep '^SUBLEVEL = ' "${KERNEL_SRC}/Makefile" | awk '{print $3}')"
[ -n "$SUBLEVEL" ] || error "SUBLEVEL not found in ${KERNEL_SRC}/Makefile"

VERSION_PATCH_DIR="${ROOT_DIR}/kernel/android14-6.1-lts"

log "Applying KernelSU-Next (pinned: ${KSUNEXT_SUSFS_FORK_REF:0:12})..."
source "${VERSION_PATCH_DIR}/ksu/ksunext/ksunext.sh"

log "Applying SUSFS (pinned: ${SUSFS_KSUNEXT_REF:0:12})..."
source "${VERSION_PATCH_DIR}/ksu/susfs/susfs.sh"

log "KernelSU-Next + SUSFS applied ✅"
