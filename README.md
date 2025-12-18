# FABRIC Generic Cluster - Notebooks

Jupyter notebooks and example topology files for the [fabric-generic-cluster](https://github.com/mcevik0/fabric-generic-cluster) framework.

## Overview

This repository contains Jupyter notebooks and YAML topology examples for creating and managing FABRIC testbed slices using the `fabric-generic-cluster` Python package.

## Prerequisites

### 1. Install the fabric-generic-cluster package
```bash
pip install fabric-generic-cluster
```

### 2. Configure FABRIC credentials
Ensure you have FABRIC testbed access configured. See [FABRIC Learn](https://learn.fabric-testbed.net/) for setup instructions.

### 3. Install Jupyter
```bash
pip install jupyter
```

## Repository Structure

```
fabric-generic-cluster-notebooks/
├── notebooks/              # Jupyter notebooks
│   ├── notebook-create-slice.ipynb                    # Main workflow: create and configure slices
│   ├── notebook-configure-slice-bluefield_dpu.ipynb   # BlueField DPU configuration
│   ├── notebook-aux-setup-environment.ipynb           # Environment setup and verification
│   ├── notebook-aux-topology-builder.ipynb            # Interactive topology builder
│   ├── notebook-aux-topology-summary-generator.ipynb  # Generate topology summaries
│   ├── notebook-aux-converter.ipynb                   # Convert notebooks to Python scripts
│   └── notebook-aux-resource-finder.ipynb             # Find available FABRIC resources
│
└── model/                  # Example YAML topology files
    ├── _slice_topology.yaml           # Basic topology example
    ├── _slice_topology_1.yaml         # Simple 2-node cluster
    ├── _slice_topology_2.yaml         # Multi-site deployment
    ├── _slice_topology_3.yaml         # Storage cluster
    ├── _slice_topology_4.yaml         # Network-intensive topology
    ├── _slice_topology_5.yaml         # Mixed workload cluster
    ├── _slice_topology_6.yaml         # High-performance computing setup
    ├── _slice_topology_7*.yaml        # OpenStack deployment variants
    ├── _slice_topology_8*.yaml        # DPU/SmartNIC configurations
    └── _slice_topology_9.yaml         # FPGA-enabled topology
```

## Quick Start

### 1. Clone this repository
```bash
git clone https://github.com/mcevik0/fabric-generic-cluster-notebooks.git
cd fabric-generic-cluster-notebooks
```

### 2. Start Jupyter
```bash
jupyter notebook
```

### 3. Run the setup notebook
Open and run `notebooks/notebook-aux-setup-environment.ipynb` to verify your environment is correctly configured.

### 4. Create your first slice
Open `notebooks/notebook-create-slice.ipynb` and follow the workflow to deploy a FABRIC slice.

## Notebooks Guide

### Core Notebooks

#### 📘 notebook-create-slice.ipynb
**Main workflow for creating and configuring FABRIC slices**

Complete workflow including:
- Loading topology from YAML
- Deploying slice to FABRIC
- Configuring L3 networks
- Setting up network interfaces
- Configuring SSH access
- Testing connectivity

**Usage:**
```python
from fabric_generic_cluster import (
    load_topology_from_yaml_file,
    deploy_topology_to_fabric,
    configure_node_interfaces,
    setup_passwordless_ssh,
)

topology = load_topology_from_yaml_file("../model/_slice_topology.yaml")
slice = deploy_topology_to_fabric(topology, "my-cluster")
configure_node_interfaces(slice, topology)
setup_passwordless_ssh(slice)
```

#### 📗 notebook-configure-slice-bluefield_dpu.ipynb
**Configure slices with NVIDIA BlueField SmartNICs**

Specialized notebook for:
- BlueField DPU deployment
- DPU configuration and management
- High-performance networking with SmartNICs
- DOCA software installation

### Auxiliary Notebooks

#### 🔧 notebook-aux-setup-environment.ipynb
**Verify and setup your Python environment**

- Check installed packages
- Install dependencies
- Verify FABRIC configuration
- Test module imports

Run this first to ensure everything is configured correctly.

#### 🏗️ notebook-aux-topology-builder.ipynb
**Interactive topology builder**

- Create topologies programmatically
- Add nodes and networks interactively
- Validate topology structure
- Export to YAML

#### 📊 notebook-aux-topology-summary-generator.ipynb
**Generate comprehensive topology summaries**

- Analyze topology files
- Generate markdown summaries
- Create network diagrams
- Export topology metadata

#### 🔄 notebook-aux-converter.ipynb
**Convert notebooks to Python scripts**

- Single or batch conversion
- Remove magic commands
- Clean output for automation
- CI/CD integration

#### 🔍 notebook-aux-resource-finder.ipynb
**Find available FABRIC resources**

- Query available sites
- Check resource availability
- Find nodes with specific hardware (DPUs, FPGAs, GPUs)
- Plan resource allocation

## Example Topologies

The `model/` directory contains example YAML topology files demonstrating various configurations:

| File | Description | Use Case |
|------|-------------|----------|
| `_slice_topology.yaml` | Basic example | Learning the topology format |
| `_slice_topology_1.yaml` | 2-node cluster | Simple experimentation |
| `_slice_topology_2.yaml` | Multi-site | Geographically distributed systems |
| `_slice_topology_3.yaml` | Storage cluster | Persistent storage testing |
| `_slice_topology_4.yaml` | Network-heavy | Network protocol research |
| `_slice_topology_7*.yaml` | OpenStack | Cloud infrastructure deployment |
| `_slice_topology_8*.yaml` | DPU/SmartNIC | Hardware acceleration |
| `_slice_topology_9.yaml` | FPGA | Custom hardware logic |

### Using Example Topologies

```python
from fabric_generic_cluster import load_topology_from_yaml_file

# Load any example topology
topology = load_topology_from_yaml_file("../model/_slice_topology_8.yaml")

# Customize for your needs
# ... modify topology ...

# Deploy
slice = deploy_topology_to_fabric(topology, "my-slice-name")
```

## Common Workflows

### Workflow 1: Deploy a Basic Cluster
```bash
1. Open notebook-create-slice.ipynb
2. Set slice_name and site_topology_yaml path
3. Run all cells
4. Wait for deployment (~5-10 minutes)
5. SSH into nodes or run experiments
```

### Workflow 2: Create Custom Topology
```bash
1. Open notebook-aux-topology-builder.ipynb
2. Interactively build your topology
3. Export to YAML in model/ directory
4. Use in notebook-create-slice.ipynb
```

### Workflow 3: BlueField DPU Deployment
```bash
1. Open notebook-configure-slice-bluefield_dpu.ipynb
2. Configure DPU settings
3. Deploy and configure BlueField
4. Access DPU via SSH or console
```

## Package Usage in Notebooks

All notebooks use the installed `fabric-generic-cluster` package:

```python
# Import from installed package
from fabric_generic_cluster import (
    load_topology_from_yaml_file,
    deploy_topology_to_fabric,
    configure_node_interfaces,
    setup_passwordless_ssh,
    print_topology_summary,
)

# Or import modules
from fabric_generic_cluster import deployment as sd
from fabric_generic_cluster import network_config as snc
```

No `sys.path` manipulation needed - everything works via pip install!

## Tips and Best Practices

### 💡 Naming Conventions
- Use descriptive slice names: `my-project-experiment-1`
- YAML files start with `_slice_topology_` for consistency

### 💡 Resource Management
- Always delete slices when done: `slice.delete()`
- Check existing slices before creating new ones
- Monitor lease expiration times

### 💡 Topology Design
- Start with example topologies
- Validate before deploying
- Use topology viewer to visualize
- Document custom topologies

### 💡 Debugging
- Use `slice.show()` to see slice details
- Check `slice.list_nodes()` and `slice.list_interfaces()`
- Verify network configuration with ping tests
- Check SSH connectivity before running commands

## Troubleshooting

### Issue: Package not found
```bash
pip install fabric-generic-cluster
# Restart Jupyter kernel
```

### Issue: FABRIC authentication failed
```bash
# Reconfigure FABRIC credentials
# See: https://learn.fabric-testbed.net/
```

### Issue: Slice deployment fails
- Check resource availability at target site
- Verify topology YAML is valid
- Ensure slice name is unique
- Check FABRIC system status

### Issue: Network configuration fails
- Verify L3 networks are configured first
- Check interface names match topology
- Ensure nodes are active before configuring

## Contributing

Found an issue or have a useful notebook to share?

1. **Framework issues**: Report at [fabric-generic-cluster](https://github.com/mcevik0/fabric-generic-cluster/issues)
2. **Notebook issues**: Report at this repository's issues
3. **Pull requests**: Contributions welcome!

## Related Resources

- **Main Package**: [fabric-generic-cluster](https://github.com/mcevik0/fabric-generic-cluster)
- **FABRIC Testbed**: [https://fabric-testbed.net/](https://fabric-testbed.net/)
- **FABRIC Learn**: [https://learn.fabric-testbed.net/](https://learn.fabric-testbed.net/)
- **PyPI Package**: [fabric-generic-cluster](https://pypi.org/project/fabric-generic-cluster/)

## License

MIT License - See LICENSE file for details

## Authors

- Mert Cevik ([@mcevik0](https://github.com/mcevik0))

## Citation

If you use this framework in your research, please cite:

```bibtex
@software{fabric_generic_cluster,
  author = {Cevik, Mert},
  title = {FABRIC Generic Cluster Framework},
  year = {2024},
  url = {https://github.com/mcevik0/fabric-generic-cluster}
}
```

---

**Questions?** Open an issue or contact via GitHub!
