# Tailscale Outbound Support Patch

This patch adds Tailscale outbound proxy support to the FlClash ClashMeta (mihomo) kernel.

## Overview

The Tailscale outbound adapter allows routing traffic through a Tailscale network using [tsnet](https://pkg.go.dev/tailscale.com/tsnet). It supports:

- TCP and UDP connections through the Tailscale network
- Authentication via auth key or interactive login
- Custom control server URL (for Headscale and other self-hosted solutions)
- Ephemeral node mode
- Accept routes from the Tailscale network
- Exit node configuration (by IP or StableNodeID)

## Files Modified

| File | Description |
|------|-------------|
| `adapter/outbound/tailscale.go` | **New** - Tailscale outbound adapter implementation |
| `adapter/parser.go` | Register `tailscale` proxy type in the proxy parser |
| `constant/adapters.go` | Add `Tailscale` adapter type constant and `String()` method |
| `docs/config.yaml` | Add Tailscale configuration example |
| `go.mod` / `go.sum` | Add `tailscale.com` dependency |

## Platform-Specific State Directory

The Tailscale adapter needs to persist state (keys, node info, etc.) to disk. The default state directory varies by platform:

| Platform | Default State Directory | Reason |
|----------|------------------------|--------|
| **Android** | `{mihomo-HomeDir}/tailscale/{name}` | Android apps have restricted file system access; `os.UserHomeDir()` may not be writable |
| **Windows/Linux/macOS** | `~/.config/mihomo/tailscale/{name}` | Standard user config directory |

Users can override this with the `state-dir` option in the proxy configuration.

## Usage

### Applying the Patch

```bash
cd <FlClash-root>
bash patches/tailscale/apply.sh
```

### Configuration Example

```yaml
proxies:
  - name: "tailscale"
    type: tailscale
    hostname: "my-exit-node"             # Required: target hostname in Tailscale network
    # authkey: "tskey-auth-xxxxx"        # Optional: auth key, needed for first connection
    # control-url: "https://controlplane.tailscale.com" # Optional: control server URL
    # ephemeral: false                   # Optional: use ephemeral node mode
    # state-dir: "/path/to/state"        # Optional: custom state directory
    # udp: true                          # Supports UDP
    # ip-version: dual                   # Optional: ipv4/ipv6/dual
    # accept-routes: true                # Optional: accept all routes
    # exit-node: "my-exit-node"          # Optional: specify exit node (IP or StableNodeID)
```
