#include <mt/command_encoder.hpp>
#include <mt/command_buffer.hpp>
#include <mt/buffer.hpp>
#include <mt/error.hpp>
#include <mt/export.hpp>
#include <mt/frame.hpp>
#include <mt/heap.hpp>
#include <mt/mt.hpp>
#include <mt/native_handle.hpp>
#include <mt/render_pass.hpp>
#include <mt/sampler.hpp>
#include <mt/shader.hpp>
#include <mt/pipeline.hpp>
#include <mt/pipeline_cache.hpp>
#include <mt/binary_archive.hpp>
#include <mt/depth_stencil.hpp>
#include <mt/binding.hpp>
#include <mt/acceleration_structure.hpp>
#include <mt/counter.hpp>
#include <mt/metal.hpp>
#include <mt/mesh.hpp>
#include <mt/argument_buffer.hpp>
#include <mt/indirect.hpp>
#include <mt/tile.hpp>
#include <mt/ray_tracing.hpp>
#include <mt/profiling.hpp>
#include <mt/surface.hpp>
#include <mt/renderer.hpp>
#include <mt/scene.hpp>
#include <mt/assets.hpp>
#include <mt/material.hpp>
#include <mt/lights.hpp>
#include <mt/built_in_shaders.hpp>
#include <mt/viewport.hpp>
#include <mt/picking.hpp>
#include <mt/input.hpp>
#include <mt/synchronization.hpp>
#include <mt/texture.hpp>
#include <mt/transfer.hpp>
#include <mt/lifetime.hpp>
#include <mt/version.hpp>

int main() {
    return mt::library_version() == nullptr ? 1 : 0;
}

