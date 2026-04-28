#!/usr/bin/env bash
# scripts/new_host.sh — generate a host_vars stub for a new host
#
# Usage: scripts/new_host.sh <hostname> <linux|windows>
set -euo pipefail

HOST="${1:-}"
OS="${2:-}"

if [ -z "$HOST" ] || [ -z "$OS" ]; then
  echo "Usage: $0 <hostname> <linux|windows>" >&2
  exit 1
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."

DEST="inventory/host_vars/${HOST}.yml"
if [ -f "$DEST" ]; then
  echo "ERROR: $DEST already exists" >&2
  exit 1
fi

case "$OS" in
  linux)
    cat > "$DEST" <<EOF
---
# host_vars/${HOST}.yml — Linux host-specific overrides
#
# Only set values here that genuinely differ from the group defaults.
# Group defaults live in inventory/group_vars/{linux,webservers,dbservers,appservers}/main.yml

# vSphere placement (REQUIRED for build_linux_vm.yml)
vsphere_template:        "rhel9-template"      # Template name in vCenter
vsphere_folder:          "/datacenter/vm/Linux"
vsphere_datastore:       "datastore1"
vsphere_network:         "VM Network"
vsphere_cpu:             4
vsphere_memory_mb:       8192
vsphere_disk_gb:         80

# Network (REQUIRED — match your environment)
static_ipv4_address:     10.10.10.NN
static_ipv4_netmask:     255.255.255.0
static_ipv4_gateway:     10.10.10.1

# Tier-specific tuning (uncomment to override group defaults)
# splunk_index_override:  ""
# apache_listen_port_ssl: 8443
EOF
    ;;

  windows)
    cat > "$DEST" <<EOF
---
# host_vars/${HOST}.yml — Windows host-specific overrides
#
# Only set values here that genuinely differ from the group defaults.
# Group defaults live in inventory/group_vars/windows/main.yml

# vSphere placement (REQUIRED for build_windows_vm.yml)
vsphere_template:        "win2022-template"    # Template name in vCenter
vsphere_folder:          "/datacenter/vm/Windows"
vsphere_datastore:       "datastore1"
vsphere_network:         "VM Network"
vsphere_cpu:             4
vsphere_memory_mb:       16384
vsphere_disk_gb:         120

# Network (REQUIRED — match your environment)
static_ipv4_address:     10.10.20.NN
static_ipv4_netmask:     255.255.255.0
static_ipv4_gateway:     10.10.20.1

# Active Directory
ad_target_ou:            "OU=Servers,OU=ExampleCoach,DC=example,DC=coach"

# Per-host software list (extends windows_install_packages from group_vars)
# windows_extra_packages:
#   - sql_server_management_studio
EOF
    ;;

  *)
    echo "ERROR: OS must be 'linux' or 'windows'" >&2
    exit 1
    ;;
esac

echo "Created $DEST"
echo "Don't forget to add '$HOST' to inventory/hosts under the right group."
