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
#include <mt/surface.hpp>
#include <mt/synchronization.hpp>
#include <mt/texture.hpp>
#include <mt/version.hpp>

int main() {
    return mt::library_version() == nullptr ? 1 : 0;
}

