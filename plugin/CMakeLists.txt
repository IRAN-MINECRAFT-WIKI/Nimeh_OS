cmake_minimum_required(VERSION 3.16)
project(NimehOSPlugin VERSION 1.0 LANGUAGES CXX)

# C++20 standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Qt auto-processing
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find Qt6 components
find_package(Qt6 REQUIRED COMPONENTS Quick Qml Gui ShaderTools Concurrent)

# Standard Qt6 project setup
qt_standard_project_setup(REQUIRES 6.5)

# ---------------------------------------------------------------------------
# Target: NimehOSPlugin (shared library)
#
# NOTE: The original task spec wrote `qt_add_executable(NimehOSPlugin SHARED ...)`,
# but `qt_add_executable` does not accept the SHARED keyword and always builds an
# executable. To get a loadable QML plugin (.so), we use `qt_add_library(... SHARED)`
# which is the canonical Qt6 way to build a QML extension plugin backing library.
# ---------------------------------------------------------------------------
qt_add_library(NimehOSPlugin SHARED
    src/plugin.cpp
)

# Tell qt_add_qml_module to use this target as the backing + plugin target.
# QML_ELEMENT-decorated classes in the SOURCES list are auto-registered.
qt_add_qml_module(NimehOSPlugin
    URI NimehOS
    VERSION 1.0
    PLUGIN_TARGET NimehOSPlugin
    SOURCES
        src/blobs/blobrect.cpp
        src/blobs/blobgroup.cpp
        src/imageanalyser/imageanalyser.cpp
    RESOURCES
        src/blobs/shaders/blob.frag
)

# ---------------------------------------------------------------------------
# Shader tools: bake blob.frag into a .qsb shader bundle so it can be loaded
# via QSGShaderEffectNode / Qt Quick's shader effect API.
# ---------------------------------------------------------------------------
qt_add_shaders(NimehOSPlugin "nimehos/blobs"
    BATCHABLE OPTIMIZED NOHLSL NOMSL
    GLSL "300es,330,440"
    PREFIX "/"
    FILES
        src/blobs/shaders/blob.frag
)

# Link Qt6 modules
target_link_libraries(NimehOSPlugin
    PUBLIC
        Qt6::Quick
        Qt6::Qml
        Qt6::Gui
        Qt6::Concurrent
)

# Treat source dirs as include roots so .hpp files can be included by basename
target_include_directories(NimehOSPlugin
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src/blobs
        ${CMAKE_CURRENT_SOURCE_DIR}/src/imageanalyser
)

# Install to the Qt6 QML import path
include(GNUInstallDirs)
install(TARGETS NimehOSPlugin
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/qt6/qml/NimehOS
    RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}/qt6/qml/NimehOS
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}/qt6/qml/NimehOS
)

install(FILES qml/NimehOS/qmldir
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/qt6/qml/NimehOS
)
