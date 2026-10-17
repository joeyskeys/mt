# Plan 20 — GUI and text integrations

**Status:** proposed — optional integration
**Scope:** ImGui and CoreText/FreeType text support
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** Plans 13, 15, 17, and 19 where a window host is required

## Goal

Add optional GUI and text consumers on top of the stable Metal wrapper without
making GUI libraries, font frameworks, or text assets part of the core target.

## Integration work owned by this plan

- An isolated ImGui target with explicit initialization, frame ownership,
  command encoding, input translation, and backend version policy.
- CoreText and optional FreeType font loading.
- Glyph atlas creation, texture upload, sampler policy, text meshes, and
  viewport label integration.
- GUI and text examples that use application-owned windows, queues, and frame
  loops.
- Independent smoke tests and package metadata for each optional dependency.

## Integration boundary

- ImGui, CoreText, and FreeType are optional dependencies and targets.
- The core `mt` library exposes render encoders and resources but does not
  initialize ImGui or own a font database.
- Font data is converted into wrapper-owned textures and mesh buffers through
  documented upload paths; the wrapper does not assume a file format.
- GUI callbacks and widgets stay in the host application. No arbitrary Swift
  closure or C++ subclass bridge is added to the core ABI.

## Implementation steps

1. Define the ImGui backend ownership, frame phases, input mapping, pipeline
   lifetime, and version compatibility policy.
2. Add optional CoreText glyph extraction and atlas generation.
3. Add FreeType as a separate selectable backend with matching glyph/atlas
   value contracts.
4. Add text mesh/texture upload helpers and viewport label integration.
5. Add windowed examples, optional target exports, and dependency-isolation
   documentation.

## Tests

- API-shape and package tests with each optional dependency enabled.
- ImGui frame/input/render smoke test using an application-owned command
  buffer.
- Glyph atlas, Unicode fallback, texture upload, sampler, and text mesh
  tests.
- Tests with all GUI/text options disabled to prove the core package remains
  independent.

## Acceptance criteria

- Applications can opt into GUI or text targets without changing the core
  `mt::mt` dependency graph.
- ImGui and text rendering follow the renderer/viewport phase contracts and
  do not steal queue, surface, or frame ownership.
- Font atlas and text mesh lifetimes are explicit and safe across in-flight
  command buffers.

## Non-goals

- Implementing the core renderer, viewport, or built-in text shader families;
  those belong to Plans 15–17.
- Making a particular GUI toolkit or font engine mandatory.
- Python, asset import, serialization, or external-resource interop.
