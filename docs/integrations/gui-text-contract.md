# GUI and text integration contract

Plan 20 is an integration layer, not a change to the graphics wrapper core.
The `mt::mt` target remains usable without ImGui, CoreText, FreeType, or any
font file.

## Target boundaries

```text
mt::mt
  ├── mt::mt-imgui       (optional ImGui coordination boundary)
  ├── mt::mt-text        (optional CoreText font/atlas/text data)
  └── mt::mt-freetype    (optional value-only bridge for external FreeType)
```

The optional targets depend on `mt::mt`; the core never depends on them.
Their generated Swift C++ headers and facade headers are installed only when
the corresponding target is enabled.

## Ownership

- The application owns the ImGui context, widgets, native font database,
  `Device`, `CommandQueue`, `CommandBuffer`, renderer, surface, and frame
  loop.
- `mt-imgui` tracks frame phases and validates/annotates an application-owned
  command buffer. It does not create an ImGui context or call widget APIs.
- `mt-text` owns value snapshots of CoreText metrics, rasterized atlas bytes,
  layout data, and optional wrapper resources created from those values.
- Atlas textures, text buffers, and samplers must remain alive until their
  command-buffer work completes. Applications may use the core retirement
  facilities for this lifetime.
- `mt-freetype` accepts glyph metrics and bitmap values produced by an
  application-owned FreeType `FT_Face`; it does not retain or destroy an
  `FT_Face` and does not link FreeType into `mt`.

## ImGui version and frame policy

The ImGui coordinator records the host's compiled/runtime version and
requires an explicit major-version match. Minor and patch compatibility is a
policy value, not an ABI guess. The host must call:

```text
initialize → beginFrame → submitDrawData/encode external backend → endFrame
```

Input is translated into value-only `ImGuiInputEvent` records. No arbitrary
Swift closure or C++ subclass is added to the generated ABI. An actual ImGui
renderer backend remains responsible for consuming ImGui draw lists and
binding its pipeline/resources.

## Text and Unicode policy

CoreText is the native macOS backend. It handles Unicode scalar lookup,
missing-glyph fallback, deterministic row-packed alpha atlases, advances,
placements, and text mesh generation. Font file parsing is outside the core
and outside `mt-text`'s required API.

FreeType support is a separate value bridge. A consumer may rasterize with
FreeType, convert the result to `FreeTypeGlyphBitmap`, and pass it to the
same atlas builder. This keeps FreeType headers, ABI, allocator, and
`FT_Face` lifetime out of all shipped `mt` targets.

## Threading and failure behavior

- ImGui coordination and CoreText/FreeType value conversion are expected on
  the application/UI thread unless the host explicitly serializes them.
- CoreText objects and host GUI objects are not sent through the core C++ ABI.
- Invalid versions, empty glyphs, unsupported pixel formats, zero-sized
  atlases, and invalid command-buffer phases return `false`/`nil` with an
  actionable diagnostic where the API provides one.
- Unsupported optional integrations are reported as unavailable; they must
  not be represented as core capabilities or silently enabled.
