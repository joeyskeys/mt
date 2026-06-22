# MT — Metal Rendering

A minimal macOS Metal 3 app written in Swift. Uses the **mesh shader geometry pipeline** (object + mesh + fragment stages) to render a colored triangle in an 800×600 window.

## Requirements

- **Apple Silicon Mac** (M1 or later) to **run** the app — mesh shaders require the Apple7 GPU family
- macOS 13+
- Xcode 15+ (Metal 3 toolchain)

> **Intel Mac note:** You can build the project on Intel, but mesh shaders only run on Apple Silicon. \
> If you previously built with `-arch arm64` on Intel and see *"incorrect executable format"*, do a clean rebuild — the binary must match your Mac's CPU (`x86_64` on Intel, `arm64` on Apple Silicon).

## Project layout

```
MT/
  main.swift          # AppKit entry point
  AppDelegate.swift   # Creates NSWindow + MTKView
  Renderer.swift      # Mesh pipeline setup + drawMeshThreadgroups
  Shaders.metal       # object_main, mesh_main, fragment_main
MT.xcodeproj          # Xcode project (arm64 only)
```

## Pipeline overview

```
object_main  →  spawns mesh threadgroups
mesh_main    →  reads vertex buffer, applies MVP, emits triangle
fragment_main → outputs uniform `color`
```

Draw calls use `drawMeshThreadgroups` instead of `drawPrimitives`.

## Build & run

### Option 1 — Xcode (recommended)

1. Open the project:
   ```bash
   open MT.xcodeproj
   ```
2. Select the **MT** scheme and **My Mac** as the run destination.
3. Press **⌘R** to build and run.

### Option 2 — Command line

```bash
xcodebuild -project MT.xcodeproj -scheme MT -configuration Debug -derivedDataPath .build/DerivedData build
open .build/DerivedData/Build/Products/Debug/MT.app
```

## What you should see

A window titled **MT — Metal** with a dark background and a solid orange triangle.

## Next steps

- Pass meshlet data through the object shader payload
- Add frustum / meshlet culling in the object stage
- Animate the MVP matrix from Swift each frame
- Load indexed mesh data from file
