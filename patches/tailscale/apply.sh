#!/usr/bin/env bash
#
# apply.sh - Apply Tailscale outbound support patches to Clash.Meta (mihomo) kernel
#
# This script adds Tailscale functionality to the FlClash ClashMeta kernel.
# It applies the following changes:
#   1. New file: adapter/outbound/tailscale.go  - Tailscale outbound adapter implementation
#   2. Patch:    adapter/parser.go              - Register tailscale proxy type
#   3. Patch:    constant/adapters.go           - Add Tailscale adapter type constant & string
#   4. Patch:    docs/config.yaml               - Add tailscale configuration example
#   5. go mod:   Add tailscale.com dependency
#
# Platform-specific behavior:
#   - Android: Default state directory uses mihomo HomeDir ({home}/tailscale/{name})
#     because Android apps have restricted file system access.
#   - Desktop (Windows/Linux/macOS): Uses ~/.config/mihomo/tailscale/{name}
#
# Usage:
#   cd <FlClash-root>
#   bash patches/tailscale/apply.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLASH_META_DIR="$REPO_ROOT/core/Clash.Meta"

# ---------------------------------------------------------------------------
# Sanity checks
# ---------------------------------------------------------------------------
if [ ! -d "$CLASH_META_DIR" ]; then
  echo "ERROR: Clash.Meta directory not found at $CLASH_META_DIR"
  echo "       Make sure submodules are initialized: git submodule update --init --recursive"
  exit 1
fi

if [ ! -f "$CLASH_META_DIR/adapter/parser.go" ]; then
  echo "ERROR: adapter/parser.go not found in $CLASH_META_DIR"
  echo "       The Clash.Meta submodule may not be properly checked out."
  exit 1
fi

echo "=== Applying Tailscale patches to Clash.Meta ==="
echo "    Clash.Meta directory: $CLASH_META_DIR"
echo ""

# ---------------------------------------------------------------------------
# 1. Copy the new tailscale.go outbound adapter
# ---------------------------------------------------------------------------
echo "[1/5] Adding adapter/outbound/tailscale.go ..."
OUTBOUND_DIR="$CLASH_META_DIR/adapter/outbound"
if [ ! -d "$OUTBOUND_DIR" ]; then
  echo "ERROR: adapter/outbound directory not found at $OUTBOUND_DIR"
  exit 1
fi

if [ -f "$OUTBOUND_DIR/tailscale.go" ]; then
  echo "      tailscale.go already exists, skipping."
else
  cp "$SCRIPT_DIR/tailscale.go" "$OUTBOUND_DIR/tailscale.go"
  echo "      Done."
fi

# ---------------------------------------------------------------------------
# 2. Patch adapter/parser.go - register tailscale proxy type
# ---------------------------------------------------------------------------
echo "[2/5] Patching adapter/parser.go ..."
PARSER_FILE="$CLASH_META_DIR/adapter/parser.go"
if grep -q '"tailscale"' "$PARSER_FILE" 2>/dev/null; then
  echo "      tailscale case already present in parser.go, skipping."
else
  # Insert the tailscale case before the 'default:' case, right after the TrustTunnel block
  # We search for the line 'proxy, err = outbound.NewTrustTunnel' and insert after it
  if grep -q 'NewTrustTunnel' "$PARSER_FILE"; then
    sed -i '/proxy, err = outbound\.NewTrustTunnel.*$/a\\tcase "tailscale":\n\t\ttailscaleOption := \&outbound.TailscaleOption{BasicOption: basicOption}\n\t\terr = decoder.Decode(mapping, tailscaleOption)\n\t\tif err != nil {\n\t\t\tbreak\n\t\t}\n\t\tproxy, err = outbound.NewTailscale(*tailscaleOption)' "$PARSER_FILE"
    echo "      Done."
  else
    echo "WARNING: Could not find TrustTunnel anchor in parser.go."
    echo "         Attempting to insert before 'default:' case..."
    sed -i '/^\tdefault:$/i\\tcase "tailscale":\n\t\ttailscaleOption := \&outbound.TailscaleOption{BasicOption: basicOption}\n\t\terr = decoder.Decode(mapping, tailscaleOption)\n\t\tif err != nil {\n\t\t\tbreak\n\t\t}\n\t\tproxy, err = outbound.NewTailscale(*tailscaleOption)' "$PARSER_FILE"
    echo "      Done (inserted before default case)."
  fi
fi

# ---------------------------------------------------------------------------
# 3. Patch constant/adapters.go - add Tailscale type constant and String()
# ---------------------------------------------------------------------------
echo "[3/5] Patching constant/adapters.go ..."
ADAPTERS_FILE="$CLASH_META_DIR/constant/adapters.go"
if grep -q 'Tailscale' "$ADAPTERS_FILE" 2>/dev/null; then
  echo "      Tailscale constant already present, skipping."
else
  # Add Tailscale to the iota enum after TrustTunnel
  if grep -q 'TrustTunnel' "$ADAPTERS_FILE"; then
    sed -i '/TrustTunnel$/a\\tTailscale' "$ADAPTERS_FILE"
    echo "      Added Tailscale to adapter type enum."
  else
    echo "WARNING: Could not find TrustTunnel in adapters.go enum."
    echo "         Trying to add before closing parenthesis of enum block..."
    # Fallback: add before the closing paren that follows the Masque/Sudoku lines
    sed -i '/^\tMasque$/a\\tTailscale' "$ADAPTERS_FILE"
    echo "      Added Tailscale after Masque."
  fi

  # Add the String() case for Tailscale
  if grep -q 'return "TrustTunnel"' "$ADAPTERS_FILE"; then
    sed -i '/return "TrustTunnel"/a\\tcase Tailscale:\n\t\treturn "Tailscale"' "$ADAPTERS_FILE"
    echo "      Added Tailscale String() case."
  else
    echo "WARNING: Could not find TrustTunnel String() case."
    sed -i '/return "Masque"/a\\tcase Tailscale:\n\t\treturn "Tailscale"' "$ADAPTERS_FILE"
    echo "      Added Tailscale String() after Masque."
  fi
fi

# ---------------------------------------------------------------------------
# 4. Patch docs/config.yaml - add tailscale example (if docs exist)
# ---------------------------------------------------------------------------
echo "[4/5] Patching docs/config.yaml ..."
DOCS_CONFIG="$CLASH_META_DIR/docs/config.yaml"
if [ ! -f "$DOCS_CONFIG" ]; then
  echo "      docs/config.yaml not found, skipping documentation patch."
else
  if grep -q 'type: tailscale' "$DOCS_CONFIG" 2>/dev/null; then
    echo "      Tailscale config example already present, skipping."
  else
    # Insert tailscale example before the masque section
    sed -i '/# masque/i\  # tailscale\n  - name: "tailscale"\n    type: tailscale\n    hostname: "my-exit-node"             # Required: target hostname in Tailscale network\n    # authkey: "tskey-auth-xxxxx"        # Optional: auth key, needed for first connection\n    # control-url: "https://controlplane.tailscale.com" # Optional: control server URL (for self-hosted Headscale etc.)\n    # ephemeral: false                   # Optional: use ephemeral node mode\n    # state-dir: "/path/to/state"        # Optional: state directory, default ~\/.config\/mihomo\/tailscale\/{name} (desktop) or {mihomo-home}\/tailscale\/{name} (Android)\n    # udp: true                          # Supports UDP\n    # ip-version: dual                   # Optional: ipv4\/ipv6\/dual\n    # accept-routes: true                # Optional: accept all routes\n    # exit-node: "my-exit-node"          # Optional: specify exit node (IP or StableNodeID)\n' "$DOCS_CONFIG"
    echo "      Done."
  fi
fi

# ---------------------------------------------------------------------------
# 5. Add tailscale.com dependency to go.mod
# ---------------------------------------------------------------------------
echo "[5/5] Adding tailscale.com dependency to go.mod ..."
GOMOD_FILE="$CLASH_META_DIR/go.mod"
if grep -q 'tailscale.com' "$GOMOD_FILE" 2>/dev/null; then
  echo "      tailscale.com dependency already present, skipping."
else
  echo "      Running 'go get tailscale.com/tsnet tailscale.com/ipn tailscale.com/tailcfg' ..."
  (
    cd "$CLASH_META_DIR"
    go get tailscale.com/tsnet tailscale.com/ipn tailscale.com/tailcfg
    go mod tidy
  )
  echo "      Done."
fi

echo ""
echo "=== Tailscale patches applied successfully ==="
echo ""
echo "Platform-specific state directory behavior:"
echo "  - Android:  {mihomo-HomeDir}/tailscale/{proxy-name}"
echo "  - Desktop:  ~/.config/mihomo/tailscale/{proxy-name}"
echo ""
echo "To build with Tailscale support, rebuild the FlClash core as usual."
