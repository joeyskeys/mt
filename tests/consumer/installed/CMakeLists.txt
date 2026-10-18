cmake_minimum_required(VERSION 3.25)

project(mt_installed_consumer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(mt CONFIG REQUIRED)

option(
    MT_INSTALLED_CONSUMER_HOSTS
    "Check optional installed AppKit/MTKView targets"
    OFF
)
option(
    MT_INSTALLED_CONSUMER_GUI_TEXT
    "Check optional installed GUI/text targets"
    OFF
)
option(
    MT_INSTALLED_CONSUMER_ASSET_PIPELINE
    "Check the optional installed asset-pipeline target"
    OFF
)
option(
    MT_INSTALLED_CONSUMER_EXTERNAL_RESOURCES
    "Check the optional installed external-resource target"
    OFF
)
option(
    MT_INSTALLED_CONSUMER_PYTHON
    "Check the optional installed Python module"
    OFF
)
set(
    MT_INSTALLED_CONSUMER_PYTHON_EXECUTABLE
    ""
    CACHE FILEPATH
    "Python interpreter used for the installed-module smoke check"
)

add_executable(mt-installed-consumer main.cpp)
target_link_libraries(mt-installed-consumer PRIVATE mt::mt)

if(MT_INSTALLED_CONSUMER_HOSTS)
    if(NOT TARGET mt::mt-appkit AND NOT TARGET mt::mt-mtkview)
        message(
            FATAL_ERROR
            "MT_INSTALLED_CONSUMER_HOSTS requires an installed host target"
        )
    endif()

    add_executable(mt-installed-host-consumer host_main.cpp)
    target_link_libraries(mt-installed-host-consumer PRIVATE mt::mt)

    if(TARGET mt::mt-appkit)
        target_link_libraries(
            mt-installed-host-consumer
            PRIVATE mt::mt-appkit
        )
        target_compile_definitions(
            mt-installed-host-consumer
            PRIVATE MT_INSTALLED_HAS_APPKIT=1
        )
    endif()

    if(TARGET mt::mt-mtkview)
        target_link_libraries(
            mt-installed-host-consumer
            PRIVATE mt::mt-mtkview
        )
        target_compile_definitions(
            mt-installed-host-consumer
            PRIVATE MT_INSTALLED_HAS_MTKVIEW=1
        )
    endif()
endif()

if(MT_INSTALLED_CONSUMER_ASSET_PIPELINE)
    if(NOT TARGET mt::mt-asset-pipeline)
        message(
            FATAL_ERROR
            "MT_INSTALLED_CONSUMER_ASSET_PIPELINE requires mt::mt-asset-pipeline"
        )
    endif()

    add_executable(
        mt-installed-asset-pipeline-consumer
        asset_pipeline_main.cpp
    )
    target_link_libraries(
        mt-installed-asset-pipeline-consumer
        PRIVATE
            mt::mt
            mt::mt-asset-pipeline
    )
    target_compile_definitions(
        mt-installed-asset-pipeline-consumer
        PRIVATE
            MT_INSTALLED_HAS_ASSET_PIPELINE=1
    )
endif()

if(MT_INSTALLED_CONSUMER_GUI_TEXT)
    if(
        NOT TARGET mt::mt-imgui
        AND NOT TARGET mt::mt-text
        AND NOT TARGET mt::mt-freetype
    )
        message(
            FATAL_ERROR
            "MT_INSTALLED_CONSUMER_GUI_TEXT requires an installed GUI/text target"
        )
    endif()

    add_executable(mt-installed-gui-text-consumer gui_text_main.cpp)
    target_link_libraries(
        mt-installed-gui-text-consumer
        PRIVATE mt::mt
    )

    if(TARGET mt::mt-imgui)
        target_link_libraries(
            mt-installed-gui-text-consumer
            PRIVATE mt::mt-imgui
        )
        target_compile_definitions(
            mt-installed-gui-text-consumer
            PRIVATE MT_INSTALLED_HAS_IMGUI=1
        )
    endif()

    if(TARGET mt::mt-text)
        target_link_libraries(
            mt-installed-gui-text-consumer
            PRIVATE mt::mt-text
        )
        target_compile_definitions(
            mt-installed-gui-text-consumer
            PRIVATE MT_INSTALLED_HAS_TEXT=1
        )
    endif()

    if(TARGET mt::mt-freetype)
        target_link_libraries(
            mt-installed-gui-text-consumer
            PRIVATE mt::mt-freetype
        )
        target_compile_definitions(
            mt-installed-gui-text-consumer
            PRIVATE MT_INSTALLED_HAS_FREETYPE=1
        )
    endif()
endif()

if(MT_INSTALLED_CONSUMER_EXTERNAL_RESOURCES)
    if(NOT TARGET mt::mt-external-resources)
        message(
            FATAL_ERROR
            "MT_INSTALLED_CONSUMER_EXTERNAL_RESOURCES requires mt::mt-external-resources"
        )
    endif()

    add_executable(
        mt-installed-external-resources-consumer
        external_resources_main.cpp
    )
    target_link_libraries(
        mt-installed-external-resources-consumer
        PRIVATE
            mt::mt
            mt::mt-external-resources
    )
    target_compile_definitions(
        mt-installed-external-resources-consumer
        PRIVATE
            MT_INSTALLED_HAS_EXTERNAL_RESOURCES=1
    )
endif()

if(MT_INSTALLED_CONSUMER_PYTHON)
    if(NOT COMMAND mt_enable_python)
        message(
            FATAL_ERROR
            "MT_INSTALLED_CONSUMER_PYTHON requires an installed Python target"
        )
    endif()
    if(MT_INSTALLED_CONSUMER_PYTHON_EXECUTABLE)
        set(
            Python3_EXECUTABLE
            "${MT_INSTALLED_CONSUMER_PYTHON_EXECUTABLE}"
            CACHE FILEPATH
            "Selected Python interpreter for the installed mt module"
            FORCE
        )
    endif()
    mt_enable_python()
    if(NOT TARGET mt::mt-python)
        message(
            FATAL_ERROR
            "The installed Python target was not exported."
        )
    endif()
endif()

