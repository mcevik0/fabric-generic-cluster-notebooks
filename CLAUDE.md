# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Environment Setup

```bash
pip install fabric-generic-cluster fabrictestbed-extensions pydantic pandas matplotlib networkx tabulate PyYAML pydot jupyter
```

FABRIC credentials must be configured separately — see [FABRIC Learn](https://learn.fabric-testbed.net/). The `FablibManager` reads from `~/.fabric/fabric_rc` and associated token files at runtime.

To convert notebooks to plain Python scripts:
```bash
jupyter nbconvert --to script notebooks/*.ipynb --output-dir scripts/
jupyter nbconvert --to script notebooks/auxilliary/*.ipynb --output-dir scripts/auxilliary/
```

## Architecture

This repo is a **notebook/example layer** on top of the [`fabric-generic-cluster`](https://github.com/mcevik0/fabric-generic-cluster) PyPI package. It does not contain library code — all logic lives in that external package.

### Data flow

```
model/*.yml  →  load_topology_from_yaml_file()  →  SiteTopology (Pydantic model)
                                                          ↓
                                              deployment.deploy_topology_to_fabric()
                                                          ↓
                                              FABRIC slice (fabrictestbed_extensions)
```

### `fabric_generic_cluster` module map

| Import alias | Responsibility |
|---|---|
| `deployment as sd` | Slice lifecycle: deploy, delete, check, configure L3/public routing |
| `network_config as snc` | Persistent interface config (NetworkManager/Netplan), ping tests |
| `ssh_setup as ssh` | Passwordless SSH key distribution and verification |
| `ansible_setup as ansible` | Ansible inventory and connectivity setup |
| `selinux_management as selinux` | SELinux mode per-node from topology |
| `topology_viewer as viewer` | Print summaries, draw graphs, export to JSON/DOT |

### YAML topology schema

Topology files under `model/` follow this structure:

```yaml
site_topology_nodes:
  nodes:
    <key>:
      name/hostname: string
      site: FABRIC_SITE_CODE   # e.g. WASH, SRI
      capacity: {cpu, ram, disk, os}
      pci:
        network:
          <nic_key>:
            model: NIC_Basic | NIC_ConnectX_5 | NIC_ConnectX_6 | ...
            interfaces:
              <iface_key>:
                binding: <network_name>   # links to a network below
                ipv4: {address, gateway, dns}
                ipv6: {address, gateway, dns}
        gpu: {<key>: {model: GPU_RTX6000 | Tesla_T4 | ...}}
        fpga: {<key>: {model: FPGA_Xilinx_U280}}
        nvme: {<key>: {model: NVME_P4510}}
        dpu: {<key>: {model: ...}}
      specific:
        openstack: {control, network, compute, storage}  # STRING 'true'/'false'
        ansible: {control, management_network, role}
        selinux: {mode: enforcing|permissive|disabled}
        postboot: "shell command string"

site_topology_networks:
  networks:
    <key>:
      name: string
      type: L2Bridge | L3 | FABNetv4 | IPv4Ext | IPv6Ext
      subnet: {ipv4: {address, gateway}, ipv6: {address, gateway}}
```

### Deployment modes (create-slice.ipynb)

The `MANUAL_DEPLOYMENT` flag controls execution path:
- `True` — run steps 7.1–7.7 individually (deploy → L3 networks → public routing → interfaces → SSH → Ansible → SELinux)
- `False` — run `sd.deploy_and_configure_slice()` which wraps all of the above

### Slice name uniqueness

`sd.check_or_generate_unique_slice_name(name, use_timestamp)` queries existing FABRIC slices and appends a suffix if the name is taken. Always use this before deploying.
