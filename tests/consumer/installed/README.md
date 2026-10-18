# Installed-package consumer

This directory is a standalone CMake consumer. It intentionally does not
include the source tree or Swift module directly. The executable validates the
installed C++ facade by checking the version, enumerating devices, creating a
queue and command buffer, submitting an encoder-free command buffer, and
running a headless offscreen clear/readback fixture:

```sh
cmake -S tests/consumer/installed -B /tmp/mt-installed-consumer \
  -DCMAKE_PREFIX_PATH=/path/to/mt/install
cmake --build /tmp/mt-installed-consumer
/tmp/mt-installed-consumer/mt-installed-consumer
```

The fixture performs the deterministic Metal work in the installed Swift
implementation and is exposed through the generated C++ facade. The
standalone consumer therefore checks installation, cross-language ownership,
and a known GPU result without a window-system dependency. The Swift runtime
suite provides broader coverage for the remaining feature paths.

When the package was installed with `MT_BUILD_APPKIT=ON` and/or
`MT_BUILD_MTKVIEW=ON`, the same consumer configure can enable
`MT_INSTALLED_CONSUMER_HOSTS=ON`. That builds `host_main.cpp` against the
installed optional targets and verifies their generated headers and aliases
without creating a window.

When the package was installed with `MT_BUILD_IMGUI=ON`,
`MT_BUILD_TEXT=ON`, or `MT_BUILD_FREETYPE_BRIDGE=ON`, the installed consumer
also enables `MT_INSTALLED_CONSUMER_GUI_TEXT=ON` to compile
`gui_text_main.cpp` against the generated optional headers and exported
targets.

When the package was installed with `MT_BUILD_ASSET_PIPELINE=ON`, the
installed consumer also enables
`MT_INSTALLED_CONSUMER_ASSET_PIPELINE=ON` to compile
`asset_pipeline_main.cpp` against `mt/asset_pipeline.hpp` and the exported
`mt::mt-asset-pipeline` target. This check does not require an importer or
codec dependency.

When the package was installed with `MT_BUILD_EXTERNAL_RESOURCES=ON`, the
installed consumer also enables
`MT_INSTALLED_CONSUMER_EXTERNAL_RESOURCES=ON` to compile
`external_resources_main.cpp` against `mt/external_resources.hpp` and
`mt::mt-external-resources`.

When the package was installed with `MT_BUILD_PYTHON=ON`, the installed
consumer can enable `MT_INSTALLED_CONSUMER_PYTHON=ON`. The package consumer
must call `mt_enable_python()` and the smoke check must be given the same
explicit interpreter used to build the module:

```sh
cmake -S tests/consumer/installed -B /tmp/mt-installed-consumer \
  -DCMAKE_PREFIX_PATH=/path/to/mt/install \
  -DMT_INSTALLED_CONSUMER_PYTHON=ON \
  -DMT_INSTALLED_CONSUMER_PYTHON_EXECUTABLE="$CONDA_PREFIX/bin/python"
```

The top-level project can run the same flow as an optional CTest entry by
enabling `MT_BUILD_INSTALLED_CONSUMER=ON`. The test installs the current
build into a temporary prefix, configures this directory with
`find_package(mt CONFIG REQUIRED)`, builds it, and runs the consumer.

