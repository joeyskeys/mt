# Installed-package consumer

This directory is a standalone CMake consumer. It intentionally does not
include the source tree or Swift module directly:

```sh
cmake -S tests/consumer/installed -B /tmp/mt-installed-consumer \
  -DCMAKE_PREFIX_PATH=/path/to/mt/install
cmake --build /tmp/mt-installed-consumer
/tmp/mt-installed-consumer/mt-installed-consumer
```

The top-level project can run the same flow as an optional CTest entry by
enabling `MT_BUILD_INSTALLED_CONSUMER=ON`. The test installs the current
build into a temporary prefix, configures this directory with
`find_package(mt CONFIG REQUIRED)`, builds it, and runs the consumer.

