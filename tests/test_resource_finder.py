"""Offline checks for the resource-finder notebooks and package delegation.

Run with: python -m unittest discover -s tests -v
Requires the updated fabric-generic-cluster package and Jupyter dependencies.
"""

import ast
from contextlib import redirect_stdout
from copy import deepcopy
import io
import json
from pathlib import Path
from types import SimpleNamespace
import unittest
from unittest.mock import Mock

from IPython.core.inputtransformer2 import TransformerManager
import nbformat

from fabric_generic_cluster import resources

NOTEBOOKS = sorted(
    (Path(__file__).resolve().parents[1] / "notebooks").glob(
        "resource-finder*.ipynb"
    )
)
PUBLIC_FUNCTIONS = {
    "get_sites_dataframe",
    "find_sites_with_resources",
    "find_hosts_with_resources",
    "validate_topology",
    "find_hosts_for_topology",
}


def notebook_cells(path):
    return json.loads(path.read_text())["cells"]


def cell_ast(cell):
    source = TransformerManager().transform_cell("".join(cell["source"]))
    return ast.parse(source)


class OfflineManager:
    """A minimal ResourcesV2 public API; it intentionally has no .sites."""

    def __init__(self, empty=False, hardware=True):
        self.empty = empty
        self.hardware = hardware
        self.site_reads = 0
        self.host_reads = 0
        self.updates = []

    def get_resources(self, update=False, force_refresh=False):
        self.updates.append((update, force_refresh))
        return self

    def get_site_names(self):
        return [] if self.empty else ["TEST"]

    def get_site(self, name):
        self.site_reads += 1
        return {
            "name": name,
            "state": "Active",
            "cores_capacity": 512,
            "ram_capacity": 1024,
            "disk_capacity": 2000,
            "components": (
                {
                    name: {"capacity": 4}
                    for name in [
                        "SharedNIC-ConnectX-6",
                        "SmartNIC-ConnectX-5",
                        "SmartNIC-ConnectX-6",
                        "SmartNIC-ConnectX-7-100",
                        "SmartNIC-ConnectX-7-400",
                        "GPU-RTX6000",
                        "GPU-A30",
                        "GPU-A40",
                        "GPU-Tesla T4",
                        "FPGA-Xilinx-U280",
                        "NVME-P4510",
                    ]
                }
                if self.hardware
                else {}
            ),
        }

    def list_hosts(self, *, output, pretty_names, quiet):
        self.host_reads += 1
        assert (output, pretty_names, quiet) == ("list", False, True)
        if self.empty:
            return []
        return [
            {
                "name": "test-worker",
                "state": "Active",
                "cores_available": 512,
                "ram_available": 1024,
                "disk_available": 2000,
                "a30_available": 2 if self.hardware else 0,
                "rtx6000_available": 2 if self.hardware else 0,
            }
        ]

    def new_slice(self, name):
        return SimpleNamespace(validate=lambda raise_exception: (True, {}))


class ResourceFinderNotebooks(unittest.TestCase):
    def test_export_example_is_opt_in(self):
        for path in NOTEBOOKS:
            with self.subTest(notebook=path.name):
                examples = [
                    "".join(cell["source"])
                    for cell in notebook_cells(path)
                    if cell["cell_type"] == "code"
                    and "# Uncomment to export" in "".join(cell["source"])
                ]
                self.assertEqual(len(examples), 1)
                source = examples[0]
                commented_call = "# export_site_availability(fablib)"
                self.assertIn("# Uncomment to export\n" + commented_call, source)
                self.assertEqual(source.count(commented_call), 1)

                exporter = Mock()
                manager = object()
                namespace = {
                    "export_site_availability": exporter,
                    "fablib": manager,
                }
                exec(compile(source, str(path), "exec"), namespace)
                exporter.assert_not_called()

                uncommented = source.replace(commented_call, commented_call[2:], 1)
                exec(compile(uncommented, str(path), "exec"), namespace)
                exporter.assert_called_once_with(manager)

    def test_json_schema_and_python_syntax(self):
        self.assertEqual(len(NOTEBOOKS), 2)
        for path in NOTEBOOKS:
            with self.subTest(notebook=path.name):
                nbformat.validate(nbformat.read(path, as_version=4))
                for cell in notebook_cells(path):
                    if cell["cell_type"] == "code":
                        compile(cell_ast(cell), str(path), "exec")

    def test_imports_resolve_to_package(self):
        for path in NOTEBOOKS:
            namespace = {}
            for cell in notebook_cells(path):
                if cell["cell_type"] != "code":
                    continue
                for node in ast.walk(cell_ast(cell)):
                    if isinstance(node, (ast.Import, ast.ImportFrom)):
                        module = ast.Module(body=[node], type_ignores=[])
                        exec(compile(module, str(path), "exec"), namespace)
            for name in PUBLIC_FUNCTIONS:
                with self.subTest(notebook=path.name, function=name):
                    self.assertIs(namespace[name], getattr(resources, name))

    def test_no_duplicate_discovery_or_obsolete_api_access(self):
        for path in NOTEBOOKS:
            for cell in notebook_cells(path):
                if cell["cell_type"] != "code":
                    continue
                for node in ast.walk(cell_ast(cell)):
                    if isinstance(node, ast.FunctionDef):
                        self.assertNotIn(node.name, PUBLIC_FUNCTIONS)
                        self.assertFalse(node.name.startswith("_"))
                    if isinstance(node, ast.Attribute):
                        self.assertNotIn(
                            node.attr,
                            {
                                "sites",
                                "site_info",
                                "get_resources",
                                "list_hosts",
                            },
                        )
                    if isinstance(node, ast.Name):
                        self.assertNotIn(
                            node.id,
                            {
                                "_RESOURCE_FIELD_MAP",
                                "_FIELD_LOOKUP",
                                "_COMPONENT_MODEL_MAP",
                            },
                        )

    def test_query_examples_use_package_with_full_bare_and_empty_data(self):
        for path in NOTEBOOKS:
            for empty, hardware in [
                (False, True),
                (False, False),
                (True, False),
            ]:
                with self.subTest(
                    notebook=path.name, empty=empty, hardware=hardware
                ):
                    manager = OfflineManager(empty=empty, hardware=hardware)
                    namespace = {}
                    namespace.update(
                        fablib=manager,
                        topology=SimpleNamespace(
                            site_topology_nodes=SimpleNamespace(
                                iter_nodes=lambda: iter(())
                            )
                        ),
                    )
                    executed = set()
                    with redirect_stdout(io.StringIO()):
                        for cell in notebook_cells(path):
                            if cell["cell_type"] != "code":
                                continue
                            tree = cell_ast(cell)
                            for statement in tree.body:
                                if isinstance(
                                    statement, (ast.Import, ast.ImportFrom)
                                ):
                                    module = ast.Module(
                                        body=[statement], type_ignores=[]
                                    )
                                    exec(
                                        compile(module, str(path), "exec"),
                                        namespace,
                                    )
                            if any(
                                isinstance(n, ast.FunctionDef)
                                for n in tree.body
                            ):
                                continue
                            calls = {
                                n.func.id
                                for n in ast.walk(tree)
                                if isinstance(n, ast.Call)
                                and isinstance(n.func, ast.Name)
                            }
                            if "get_sites_dataframe" in calls:
                                exec(
                                    compile(tree, str(path), "exec"), namespace
                                )
                                executed.add("get_sites_dataframe")
                            else:
                                # Run standalone examples, excluding setup,
                                # model loading and export side effects.
                                for statement in tree.body:
                                    if (
                                        isinstance(statement, ast.Expr)
                                        and isinstance(
                                            statement.value, ast.Call
                                        )
                                        and isinstance(
                                            statement.value.func, ast.Name
                                        )
                                        and statement.value.func.id
                                        in PUBLIC_FUNCTIONS
                                    ):
                                        module = ast.Module(
                                            body=[deepcopy(statement)],
                                            type_ignores=[],
                                        )
                                        exec(
                                            compile(module, str(path), "exec"),
                                            namespace,
                                        )
                                        executed.add(statement.value.func.id)
                    self.assertEqual(executed, PUBLIC_FUNCTIONS)
                    self.assertGreater(manager.host_reads, 0)
                    self.assertIn((True, True), manager.updates)
                    if not empty:
                        self.assertGreater(manager.site_reads, 0)


if __name__ == "__main__":
    unittest.main()
