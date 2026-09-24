# Codex Instructions for fabric-generic-cluster-notebooks

## Purpose

This repository contains Jupyter notebooks and YAML model files used to define and run FABRIC Testbed experiments.

When working with topology model files, Codex should use the existing repository contents as the primary source for repository conventions and established patterns, subject to the current library/schema behavior and the user's requested topology.

## Repository Scope

Topology YAML files are stored under:

```text
model/
```

Jupyter notebooks and supporting code may consume these model files.

Unless explicitly requested otherwise, topology-generation tasks should modify only files under `model/`.

## General Working Rules

1. Inspect the repository before making changes.
2. Prefer existing repository conventions over generic FABRIC or FABlib examples.
3. Make the smallest change required to satisfy the request.
4. Do not modify unrelated notebooks, Python files, documentation, or existing topology files unless explicitly requested.
5. Do not perform broad refactoring while generating or updating topology models.
6. Preserve backward compatibility with existing repository usage whenever possible.

## Creating New Topology Models

Before creating a new YAML topology file:

1. Inspect the existing YAML files under `model/`.
2. Identify the existing model or models that most closely resemble the requested topology.
3. Use those files as the primary reference for:
   - YAML structure
   - field names
   - field ordering
   - indentation
   - node naming
   - network naming
   - site specification
   - image naming
   - capacity definitions
   - component definitions
   - FABRIC hardware types
   - network service definitions
4. Prefer combining established patterns from multiple existing models when no single model matches the request.

Do not invent new fields, structures, component names, or schema elements merely because they appear plausible.

If the requested feature is not represented in the existing models, or fields or structures are uncertain, inspect the repository code and the current `fabric-generic-cluster` model/schema implementation (`fabric_generic_cluster/models.py`) before introducing a new representation.

## Existing Models as Primary References

Treat files already present under `model/` as primary references for repository conventions and established patterns. Do not blindly copy stale, inconsistent, or experiment-specific values, or reproduce known errors. If an example conflicts with the current `fabric-generic-cluster` schema/library behavior or the user's requested topology, resolve the inconsistency rather than reproducing it.

When generating a topology:

- follow existing naming conventions;
- preserve the style and formatting of neighboring YAML files;
- reuse established FABRIC component identifiers;
- reuse established image names where appropriate;
- reuse compatible node and network structures.

Repository-local examples take precedence over generic examples from model knowledge.

Copy only configuration relevant to the requested topology. Do not automatically inherit worker placement, application roles, postboot commands, SELinux settings, management-network values, or other unrelated experiment configuration from a reference model.

## File Creation

Unless the user specifies a filename:

- choose a short, descriptive lowercase filename;
- use hyphens or the naming convention already established under `model/`;
- use the `.yml` extension, following the existing topology models.

Do not overwrite an existing topology file unless explicitly requested.

If an existing file appears to be the natural template, copy its structure conceptually and create a new file rather than modifying the original.

## FABRIC Components and Hardware

When adding hardware components such as:

- SmartNICs
- ConnectX NICs
- GPUs
- FPGAs
- NVMe devices
- shared NICs

first inspect existing model files for the exact component names and representation used by this repository.

Do not guess FABRIC component model names when an existing repository example is available.

When hardware availability or naming differs between FABlib versions, prefer the conventions already used by the current repository and its associated `fabric-generic-cluster` library.

## Sites

When the user explicitly specifies FABRIC sites, preserve those site constraints.

When the user does not specify sites:

- do not inherit a reference model's site pinning unless required by the intended topology;
- check the current library's support for omitted or empty site values for automatic site selection, even when existing examples specify sites explicitly.

Preserve placement constraints required by the intended topology. For unresolved placement choices that materially affect the topology, follow the ambiguity guidance below.

## Networks

When defining FABRIC network services:

1. Identify similar network definitions in existing model files.
2. Preserve existing representations for:
   - L2 networks
   - L3 networks
   - point-to-point connectivity
   - multi-node networks
   - inter-site connectivity
3. Preserve existing interface and network naming patterns.

Do not invent a new network representation when an equivalent established pattern exists.

## Network Addressing and Interface Inference

When generating network configuration from existing topology models:

- infer repository conventions for interface names, NIC names, connection names, device names, bindings, and network-service structure from the closest existing examples;
- do not blindly copy experiment-specific IP addresses, subnets, gateways, DNS settings, site assignments, or other topology-specific values;
- when IP addressing is not explicitly provided, inspect existing models for established addressing conventions and choose a consistent private addressing scheme only when that is appropriate for the requested topology;
- ensure generated IP addresses are unique, belong to the intended subnet, and are internally consistent with interface and network bindings;
- report any inferred addressing scheme in the final summary;
- if addressing, placement, or connectivity is materially ambiguous, surface the ambiguity rather than silently copying values from a reference model.

Existing model files should guide how network configuration is represented, but their literal address values should not be treated as defaults unless the request or repository convention clearly makes them reusable.

## Analysis-Only Requests

If the user asks only for review, analysis, inspection, explanation, comparison, recommendations, or identification of a suitable model, do not modify files.

A prompt such as "review and fix this topology" includes an explicit implementation request and authorizes the requested edits. Words such as "review" or "analyze" do not override an explicit request to modify files.

For analysis-only requests, report:

- relevant model files;
- applicable patterns;
- potential issues;
- recommended implementation approach.

For analysis-only requests, wait for an explicit implementation request before changing files.

## Modification Requests

When the user asks to create or modify a topology:

1. Inspect relevant existing models.
2. Identify the closest reference files.
3. Make the requested change.
4. Keep the diff minimal.
5. Validate the result.
6. Summarize what changed.

Do not redesign unrelated repository structures.

## Validation

After creating or modifying YAML files, validate the changed files first, including newly created files, before reporting completion. Select files explicitly rather than blindly scanning all models; accept both `.yml` and `.yaml` where applicable, and fail visibly if no files were selected. Report unrelated pre-existing failures from any broader checks separately from failures caused by the current change.

At minimum:

1. verify that the YAML parses successfully;
2. check indentation and YAML structure;
3. check for duplicate or malformed keys where practical;
4. compare the resulting structure against relevant existing patterns and the current library/schema.

`yaml.safe_load` does not detect duplicate mapping keys. If checking for duplicates, use an additional check such as a YAML linter configured to reject duplicate keys or a custom loader that rejects them.

If an appropriate Python YAML parser is available, the following checks syntax for explicitly selected files. Replace the example path with the actual changed model paths; multiple `.yml` or `.yaml` paths may be passed:

```bash
python - model/rocky9-4node-smartnic.yml <<'PY'
import pathlib
import sys
import yaml

paths = [pathlib.Path(arg) for arg in sys.argv[1:]]
if not paths:
    raise SystemExit("No model files selected; pass changed .yml or .yaml paths.")

for path in paths:
    if path.suffix not in {".yml", ".yaml"} or not path.is_file():
        raise SystemExit(f"Invalid model file: {path}")
    with path.open() as f:
        yaml.safe_load(f)
    print(f"YAML syntax OK: {path}")
PY
```

Use repository-provided validation tools or relevant model-parsing tests when available. Where practical, load changed files with `fabric_generic_cluster.load_topology_from_yaml_file` for library/schema validation, consulting the current model/schema implementation to resolve uncertain fields or structures.

Also perform basic semantic checks where practical:

- node names are unique;
- network names are unique;
- interface/network bindings reference declared networks;
- management-network references identify declared networks bound to interfaces on the corresponding node;
- static addressing is internally consistent, including address families, prefixes, subnets, gateways, and duplicate addresses within a network.

These checks supplement YAML syntax validation; neither syntax, schema loading, nor semantic checks prove that FABRIC deployment will succeed.

Do not install new dependencies solely for validation unless explicitly requested.

## Validation Boundaries

Generating or validating a YAML topology does not authorize submitting a FABRIC slice. Do not run deployment notebooks or deployment actions merely as validation. Slice creation, submission, modification, or deletion requires an explicit user request.

Do not claim that a topology has been successfully deployed to FABRIC unless it was actually submitted and verified against FABRIC.

Distinguish between:

- YAML syntax validation;
- repository/schema validation;
- notebook/library loading;
- FABlib topology construction;
- actual FABRIC slice creation.

Report only the validation that was actually performed.

## Reporting Changes

After creating or modifying a model, summarize:

1. the file created or modified;
2. the existing model files used as references;
3. the important topology characteristics;
4. validation performed;
5. any assumptions made.

For example:

```text
Created:
  model/rocky9-4node-smartnic.yml

References:
  model/example-a.yml
  model/example-b.yml

Topology:
  - 4 Rocky Linux 9 nodes
  - shared L2 network
  - ConnectX-6 SmartNIC on node1
  - site constrained to RENC

Validation:
  - YAML parsing passed
  - structure compared with existing model files
```

## Minimal-Diff Policy

Prefer minimal and reviewable changes.

Do not:

- reformat unrelated YAML files;
- reorder unrelated sections;
- rename existing models;
- modify notebooks unnecessarily;
- change library code while generating topology files;
- update dependencies unless required by the request.

## Handling Ambiguity

When a topology request leaves minor implementation details unspecified, infer them from existing repository examples when there is a clear convention.

Examples include:

- node naming;
- interface naming;
- YAML field ordering;
- default capacity formatting;
- network naming.

Avoid asking for clarification when an existing repository convention provides a reasonable answer.

If an ambiguity materially changes placement, connectivity, or requested experiment behavior and cannot be resolved from repository conventions and current library behavior, surface it to the user before implementing the affected part rather than silently choosing a materially different topology. Report any minor assumptions in the final summary.

## Recommended Workflow

For topology-generation tasks, use this sequence:

```text
1. Inspect model/
2. Identify closest examples
3. Understand requested topology
4. Reuse established repository patterns
5. Create the new YAML file
6. Validate changed YAML files and check topology semantics
7. Run relevant repository checks when available
8. Review the diff
9. Report references, assumptions, and validation
```

## Safety for Existing Models

Existing topology models may represent working FABRIC experiments.

Therefore:

- preserve existing files by default;
- create new models rather than overwriting existing ones;
- modify an existing model only when the user explicitly requests it;
- avoid bulk transformations across `model/` unless explicitly requested.

## Final Principle

When generating FABRIC topology models:

> Use existing models as primary references for conventions and established patterns, resolve conflicts with current library behavior and the requested topology, make the smallest necessary change, and validate changed files before reporting completion.
