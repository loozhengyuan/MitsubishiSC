# The following lines of boilerplate have to be in your project's
# CMakeLists in this exact order for cmake to work correctly
cmake_minimum_required(VERSION 3.22)

include($ENV{IDF_PATH}/tools/cmake/project.cmake)

project(MitsubishiSC)

# "Trim" the build. Include the minimal set of components, main, and anything it depends on.
idf_build_set_property(MINIMAL_BUILD ON)

idf_build_set_property(CXX_COMPILE_OPTIONS "-std=gnu++2a;-Os;-DCHIP_HAVE_CONFIG_H" APPEND)
idf_build_set_property(C_COMPILE_OPTIONS "-Os" APPEND)
# For RISCV chips, project_include.cmake sets -Wno-format, but does not clear various
# flags that depend on -Wformat
idf_build_set_property(COMPILE_OPTIONS "-Wno-format-nonliteral;-Wno-format-security" APPEND)

# GCC 14 + C++20: ClosureControl structs need same-type operator== for std::optional.
# Mirrors esp32-arduino-lib-builder, which force-includes the patch header shipped
# with arduino-esp32 into esp_matter.
# TODO: Remove when upgrading to Arduino Core v4 (ESP Matter 1.6, IDF 6.1), which
# no longer requires this patch. See https://github.com/espressif/arduino-esp32/pull/12730
idf_component_get_property(arduino_dir espressif__arduino-esp32 COMPONENT_DIR)
idf_component_get_property(esp_matter_lib espressif__esp_matter COMPONENT_LIB)
target_compile_options(${esp_matter_lib} PRIVATE
    "SHELL:-include \"${arduino_dir}/libraries/Matter/src/matter_closure_patch.h\"")
