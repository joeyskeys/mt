#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="${MT_VALIDATION_BUILD_ROOT:-${ROOT_DIR}/.validation-build}"

for build_type in Debug Release; do
    build_dir="${BUILD_ROOT}/cmake-${build_type}"
    cmake -S "${ROOT_DIR}" -B "${build_dir}" \
        -DCMAKE_BUILD_TYPE="${build_type}" \
        -DMT_BUILD_TESTS=ON \
        -DMT_BUILD_EXAMPLES=ON \
        -DMT_BUILD_INSTALLED_CONSUMER=ON
    cmake --build "${build_dir}" --config "${build_type}"
    ctest --test-dir "${build_dir}" \
        --build-config "${build_type}" \
        --output-on-failure
done

swift build \
    --package-path "${ROOT_DIR}" \
    --configuration debug
swift test \
    --package-path "${ROOT_DIR}" \
    --configuration debug
swift build \
    --package-path "${ROOT_DIR}" \
    --configuration release

if [[ "${MT_VALIDATE_OPTIONAL_HOSTS:-0}" == "1" ]]; then
    host_build_dir="${BUILD_ROOT}/cmake-optional-hosts"
    cmake -S "${ROOT_DIR}" -B "${host_build_dir}" \
        -DCMAKE_BUILD_TYPE=Debug \
        -DMT_BUILD_TESTS=ON \
        -DMT_BUILD_EXAMPLES=ON \
        -DMT_BUILD_APPKIT=ON \
        -DMT_BUILD_MTKVIEW=ON \
        -DMT_BUILD_HOST_EXAMPLES=ON \
        -DMT_BUILD_INSTALLED_CONSUMER=ON
    cmake --build "${host_build_dir}" --config Debug
    ctest --test-dir "${host_build_dir}" \
        --build-config Debug \
        --output-on-failure \
        -R 'mt\.unit\.host\.'
fi

if [[ "${MT_VALIDATE_GUI_TEXT:-0}" == "1" ]]; then
    gui_text_build_dir="${BUILD_ROOT}/cmake-gui-text"
    cmake -S "${ROOT_DIR}" -B "${gui_text_build_dir}" \
        -DCMAKE_BUILD_TYPE=Debug \
        -DMT_BUILD_TESTS=ON \
        -DMT_BUILD_EXAMPLES=ON \
        -DMT_BUILD_APPKIT=ON \
        -DMT_BUILD_IMGUI=ON \
        -DMT_BUILD_TEXT=ON \
        -DMT_BUILD_FREETYPE_BRIDGE=ON \
        -DMT_BUILD_GUI_TEXT_EXAMPLES=ON \
        -DMT_BUILD_INSTALLED_CONSUMER=ON
    cmake --build "${gui_text_build_dir}" --config Debug
    ctest --test-dir "${gui_text_build_dir}" \
        --build-config Debug \
        --output-on-failure \
        -R 'mt\.unit\.gui_text\.|mt\.consumer\.installed'
fi

if [[ "${MT_VALIDATE_ASSET_PIPELINE:-0}" == "1" ]]; then
    asset_build_dir="${BUILD_ROOT}/cmake-asset-pipeline"
    cmake -S "${ROOT_DIR}" -B "${asset_build_dir}" \
        -DCMAKE_BUILD_TYPE=Debug \
        -DMT_BUILD_TESTS=ON \
        -DMT_BUILD_EXAMPLES=ON \
        -DMT_BUILD_ASSET_PIPELINE=ON \
        -DMT_BUILD_ASSET_PIPELINE_EXAMPLES=ON \
        -DMT_BUILD_INSTALLED_CONSUMER=ON
    cmake --build "${asset_build_dir}" --config Debug
    ctest --test-dir "${asset_build_dir}" \
        --build-config Debug \
        --output-on-failure \
        -R 'mt\.unit\.asset_pipeline\.|mt\.consumer\.installed'
fi

if [[ "${MT_VALIDATE_PYTHON:-0}" == "1" \
    || "${MT_VALIDATE_EXTERNAL_RESOURCES:-0}" == "1" ]]; then
    optional_build_dir="${BUILD_ROOT}/cmake-language-external"
    optional_args=(
        "-DMT_BUILD_TESTS=ON"
        "-DMT_BUILD_EXAMPLES=ON"
        "-DMT_BUILD_INSTALLED_CONSUMER=ON"
    )

    if [[ "${MT_VALIDATE_EXTERNAL_RESOURCES:-0}" == "1" ]]; then
        optional_args+=("-DMT_BUILD_EXTERNAL_RESOURCES=ON")
    fi

    if [[ "${MT_VALIDATE_PYTHON:-0}" == "1" ]]; then
        : "${MT_PYTHON_EXECUTABLE:?MT_VALIDATE_PYTHON=1 requires MT_PYTHON_EXECUTABLE to be set explicitly}"
        optional_args+=(
            "-DMT_BUILD_PYTHON=ON"
            "-DMT_PYTHON_EXECUTABLE=${MT_PYTHON_EXECUTABLE}"
        )
        if [[ -n "${MT_PYTHON_ROOT:-}" ]]; then
            optional_args+=("-DMT_PYTHON_ROOT=${MT_PYTHON_ROOT}")
        fi
        if [[ -n "${MT_PYTHON_INCLUDE_DIR:-}" ]]; then
            optional_args+=("-DMT_PYTHON_INCLUDE_DIR=${MT_PYTHON_INCLUDE_DIR}")
        fi
        if [[ -n "${MT_PYTHON_LIBRARY:-}" ]]; then
            optional_args+=("-DMT_PYTHON_LIBRARY=${MT_PYTHON_LIBRARY}")
        fi
        if [[ -n "${MT_PYTHON_INSTALL_DIR:-}" ]]; then
            optional_args+=("-DMT_PYTHON_INSTALL_DIR=${MT_PYTHON_INSTALL_DIR}")
        fi
    fi

    cmake -S "${ROOT_DIR}" -B "${optional_build_dir}" \
        -DCMAKE_BUILD_TYPE=Debug \
        "${optional_args[@]}"
    cmake --build "${optional_build_dir}" --config Debug
    ctest --test-dir "${optional_build_dir}" \
        --build-config Debug \
        --output-on-failure \
        -R 'mt\.unit\.(python|external_resources)\.|mt\.consumer\.installed'
fi

echo "Package validation completed for Debug, Release, and SwiftPM."
