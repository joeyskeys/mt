# Language and external-resource integration contract

Plan 22 is optional integration work. The core `mt::mt` target remains
usable without Python, IOSurface, media frameworks, or producer-specific
libraries.

## Python boundary

The Python extension is a small CPython module named `mt`. It consumes the
installed C++ facade; it does not import Swift modules or expose Metal
implementation objects directly.

Enable it explicitly:

```sh
cmake -S . -B build-python \
  -DMT_BUILD_PYTHON=ON \
  -DMT_PYTHON_EXECUTABLE="$CONDA_PREFIX/bin/python" \
  -DMT_PYTHON_ROOT="$CONDA_PREFIX"
```

`MT_PYTHON_EXECUTABLE` is the authoritative interpreter selection. The root,
include-directory, and library cache variables are overrides for installations
whose layout cannot be inferred from the interpreter:

- `MT_PYTHON_ROOT`
- `MT_PYTHON_INCLUDE_DIR`
- `MT_PYTHON_LIBRARY`
- `MT_PYTHON_INSTALL_DIR`

Python support is disabled by default. A normal `find_package(mt)` consumer
does not acquire a Python dependency. A consumer of an installation that
contains the extension must call `mt_enable_python()` before using the
exported `mt::mt-python` target.

The first binding surface intentionally contains value-oriented version and
device queries. `mt.Device` is an owned Python handle around the C++ device
handle; destroying the Python object releases that handle. The binding does
not start worker threads, retain borrowed pointers, or perform asynchronous
work behind the caller's back. Calls execute while holding the GIL. Python
exceptions represent binding or wrapper failures; Metal command completion
and synchronization remain explicit wrapper operations.

## External-resource boundary

The optional `MTExternalResources`/`mt::mt-external-resources` target handles
IOSurface-backed textures and buffers. It is separate from `mt/mt.hpp` and
requires `IOSurface`, `Metal`, and `Foundation` only when enabled.

Descriptors carry:

- IOSurface identity, dimensions, plane/range, format, and usage;
- an explicit shared/managed storage and CPU cache-mode request;
- borrowed versus retained ownership;
- an application label for diagnostics.

Borrowed mode leaves producer lifetime and use-count decisions with the
producer. Retained mode keeps the imported wrapper and an IOSurface use count
alive until the imported object is destroyed. Neither mode transfers
ownership of the producer's window, queue, media graph, or event loop.

The importer validates descriptors, surface availability, dimensions, ranges,
device identity, supported formats, and Metal import success before returning
an imported wrapper. Only IOSurface-compatible shared or managed storage is
accepted; private and memoryless requests are rejected before import.
Unsupported combinations fail with structured diagnostics; they are not
silently converted to a different format, cache mode, or storage mode.

`ExternalSharedEventBridge` provides an explicit shared-event wait/signal
boundary. The producer and consumer agree on monotonically meaningful values
and apply the policy before encoding or after encoding as requested. The
bridge does not infer cross-process synchronization or hide a queue handoff.

## Configuration and fallback

Core and host builds must not turn on either optional target implicitly.
Applications that cannot provide IOSurface or a selected Python installation
should leave the corresponding option disabled and use ordinary wrapper
resources or value-only C++ APIs.

The optional validation path is explicit as well:

```sh
MT_VALIDATE_PYTHON=1 \
MT_PYTHON_EXECUTABLE="$CONDA_PREFIX/bin/python" \
bash scripts/validate_package.sh
```

The script refuses to run its Python validation path without
`MT_PYTHON_EXECUTABLE`; it never chooses a system or Homebrew interpreter on
the user's behalf. Set `MT_VALIDATE_EXTERNAL_RESOURCES=1` to include the
IOSurface target in the same opt-in validation build.
