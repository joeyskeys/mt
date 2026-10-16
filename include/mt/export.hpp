#pragma once

// The first release targets macOS. Keep the macro isolated so the ABI
// boundary can add platform-specific visibility rules without changing every
// public declaration.
#if defined(_WIN32) && defined(MT_BUILDING_SHARED)
#    if defined(MT_BUILDING_LIBRARY)
#        define MT_API __declspec(dllexport)
#    else
#        define MT_API __declspec(dllimport)
#    endif
#elif defined(__GNUC__) || defined(__clang__)
#    define MT_API __attribute__((visibility("default")))
#else
#    define MT_API
#endif

