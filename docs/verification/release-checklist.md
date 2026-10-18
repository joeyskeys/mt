# Plan 18 release checklist

The automated package check is intentionally separate from device-specific
evidence:

```sh
bash scripts/validate_package.sh
```

For optional host targets, repeat the package check with:

```sh
MT_VALIDATE_OPTIONAL_HOSTS=1 bash scripts/validate_package.sh
```

For optional GUI/text targets, also run:

```sh
MT_VALIDATE_GUI_TEXT=1 bash scripts/validate_package.sh
```

Before recording a release result on a verification Mac:

1. Run the script in both Debug and Release.
2. Run with Metal API validation enabled and retain any diagnostics.
3. Run the offscreen Swift suite and the installed C++ consumer.
   For a windowed host pass, set `MT_RUN_WINDOWED_HOST_TESTS=1` and run the
   AppKit/MTKView integration tests on the main display.
4. Run capability-specific examples only after checking
   `Device.capabilities`/`MetalCapabilityAvailability`.
5. Capture representative renderer, tile/memoryless, mesh, and viewport
   frames in Xcode when those paths are supported.
6. Record macOS, SDK, Swift/Xcode, commit, device registry ID, and build
   configuration in a JSON result.
7. Store performance measurements with sample counts and units; do not
   compare measurements from different devices as if they were portable.

A passed compile or package install is not GPU evidence. Unsupported native
features must be recorded as `unsupported` with their diagnostic and
documented fallback, while checks that were skipped remain `not_run`.
