# Codex Instructions for fabric-generic-cluster-notebooks

## Purpose

This repository contains Jupyter notebooks and YAML model files used to define and run FABRIC Testbed experiments.

When working with topology model files, Codex should use the existing repository contents as the primary source of truth for structure, conventions, and supported patterns.

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

If the requested feature is not represented in the existing models, inspect the repository code or current project schema before introducing a new representation.

## Existing Models Are Authoritative Examples

Treat files already present under `model/` as repository-local reference implementations.

When generating a topology:

- follow existing naming conventions;
- preserve the style of neighboring YAML files;
- reuse established FABRIC component identifiers;
- reuse established image names where appropriate;
- use existing node and network structures;
- maintain consistent formatting.

Repository-local examples take precedence over generic examples from model knowledge.

## File Creation

Unless the user specifies a filename:

- choose a short, descriptive lowercase filename;
- use hyphens or the naming convention already established under `model/`;
- use the `.yaml` extension if that is the repository convention.

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

- do not arbitrarily hard-code a site unless existing repository behavior requires it;
- preserve the repository's existing approach to site selection.

If site selection affects the topology structure, explain the assumption before or after making the change.

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

## Analysis-Only Requests

If the user asks to:

- review,
- analyze,
- inspect,
- explain,
- compare,
- recommend,
- identify a suitable model,

do not modify files.

For analysis-only requests, report:

- relevant model files;
- applicable patterns;
- potential issues;
- recommended implementation approach.

Wait for an explicit implementation request before changing files.

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

After creating or modifying YAML files, validate them before reporting completion.

At minimum:

1. verify that the YAML parses successfully;
2. check indentation and YAML structure;
3. check for duplicate or malformed keys where practical;
4. compare the resulting structure against similar existing model files.

Use repository-provided validation tools or tests when available.

If an appropriate Python YAML parser is available, a syntax check similar to the following is acceptable:

```bash
python - <<'PY'
import pathlib
import yaml

for path in pathlib.Path("model").glob("*.yaml"):
    with path.open() as f:
        yaml.safe_load(f)
    print(f"OK: {path}")
PY
```

Do not install new dependencies solely for validation unless explicitly requested.

If repository tests cover model parsing or topology loading, run the relevant tests when practical.

## Validation Boundaries

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
  model/rocky9-4node-smartnic.yaml

References:
  model/example-a.yaml
  model/example-b.yaml

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

If an ambiguity materially changes the topology semantics, identify the assumption in the final summary.

## Recommended Workflow

For topology-generation tasks, use this sequence:

```text
1. Inspect model/
2. Identify closest examples
3. Understand requested topology
4. Reuse established repository patterns
5. Create the new YAML file
6. Validate YAML
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

> Use the repository's existing models as the authoritative examples, make the smallest necessary change, and validate the resulting YAML before reporting completion.
