# `mt` verification records

Plan 18 stores runtime evidence separately from source and capability design.
Each record is JSON and follows [`result.schema.json`](result.schema.json).
Start from [`result-template.json`](result-template.json), then preserve the
completed record under `docs/verification/results/` with a device/build
identifier in its filename.

Required run metadata:

- macOS version and Xcode/SDK/Swift versions;
- `mt` commit and Debug/Release configuration;
- device name, registry ID, device type, unified-memory flag, and Metal
  family;
- Metal API validation and GPU-capture settings;
- test/example command and its result.

Use these result states:

- `passed`: the behavior was executed and matched its expected result;
- `failed`: the behavior was executed and did not match;
- `unsupported`: the device or OS explicitly reports the capability as
  unavailable;
- `not_run`: the check was not executed.

`unsupported` and `not_run` are intentionally different. A CPU architecture
or machine name must never be used to infer a Metal capability. Capability
records should include the wrapper diagnostic and the selected fallback when a
native path is unavailable.

The checked-in template contains no successful runtime claims. Results are
added only after a Metal-capable verification run and should include the exact
command, commit, SDK, and configuration used to produce them.
