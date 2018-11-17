cmake_minimum_required(VERSION 3.9)

if (DEFINED STM32_LIBRARIES_PATH)
    set(stm32_libraries_root_dir ${STM32_LIBRARIES_PATH})
endif()

if (stm32_libraries_root_dir)
    message(STATUS "STM32 Libraries path: ${stm32_libraries_root_dir}")
else ()
    message(FATAL_ERROR "STM32 Libraries can't be found. Please set environment variable: STM32_LIBRARIES_ROOT_DIR or pass path to cmake with -DSTM32_LIBRARIES_PATH")
endif ()

string(TOLOWER "${mcu}" mcu)

string(REGEX MATCH "stm32f10..."
    mcu_startup_filename ${mcu})

string(REGEX MATCH ".$"
    mcu_version ${mcu_startup_filename})

string(REGEX MATCH "stm32f10."
    mcu_startup_filename ${mcu_startup_filename})

set(mcu_startup_filename_path "startup_${mcu_startup_filename}x${mcu_version}.s")

file(GLOB_RECURSE stm32_startup_file ${stm32_libraries_root_dir}/**/${mcu_startup_filename_path})

if (NOT stm32_startup_file)
    if ("${mcu_version}" STREQUAL "8")
        set(mcu_version "b")
    endif ()
endif ()

set(mcu_startup_filename_path "startup_${mcu_startup_filename}x${mcu_version}.s")

file(GLOB_RECURSE stm32_startup_file ${stm32_libraries_root_dir}/**/${mcu_startup_filename_path})

string(TOUPPER "${mcu_startup_filename}" mcu_prefix_uppercased)

string (TOUPPER "${mcu_version}" mcu_version_uppercased)

set(mcu_definition "${mcu_prefix_uppercased}x${mcu_version_uppercased}")
message(STATUS "Added compilation definition: -D${mcu_definition}")

add_definitions("-D${mcu_definition}")


# only gcc version currently supported
list(FILTER stm32_startup_file INCLUDE REGEX ".*gcc.*")

if (NOT EXISTS "${stm32_startup_file}")
    message(FATAL_ERROR "Can't find gcc_ride7/${mcu_startup_filename} under: ${stm32_libraries_root_dir}")
else ()
    message(STATUS "Found startup script: ${stm32_startup_file}")
endif ()

file(GLOB_RECURSE stm32_device_support_sources
    ${stm32_libraries_root_dir}/**/stm32f1xx.h
    ${stm32_libraries_root_dir}/**/system_stm32f1xx.h
    ${stm32_libraries_root_dir}/**/system_stm32f1xx.c
)

list(FILTER stm32_device_support_sources INCLUDE REGEX ".*CMSIS/Device/ST.*")

list(GET stm32_device_support_sources 0 device_support_element)

get_filename_component(stm32_device_support_path ${device_support_element} DIRECTORY)

file(GLOB_RECURSE cmsis_core_file
    ${stm32_libraries_root_dir}/**/core_cm3.h
)

get_filename_component(cmsis_core_file_path ${cmsis_core_file} DIRECTORY)

file(GLOB sources
    ${stm32_startup_file}
    ${cmsis_core_file}
    ${stm32_device_support_sources}
)

add_library(stm32 ${sources})

target_sources(stm32 PUBLIC ${sources})

target_include_directories(stm32 PUBLIC
    ${stm32_device_support_path}
    ${cmsis_core_file_path}
)



list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(cmake/AddTargetCompileOptions.cmake)
add_target_compile_options(stm32)

set_target_properties(stm32 PROPERTIES LINK_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--gc-sections")
set_property(TARGET stm32 PROPERTY INTERPROCEDURAL_OPTIMIZATION true)

set(CMAKE_C_FLAGS "-mthumb -mcpu=cortex-m3 -mfloat-abi=soft" CACHE INTERNAL "c compiler flags")
set(CMAKE_CXX_FLAGS "-mthumb -mcpu=cortex-m3 -mfloat-abi=soft -Wno-register" CACHE INTERNAL "cxx compiler flags")
set(CMAKE_ASM_FLAGS "-mthumb -mcpu=cortex-m3 -mfloat-abi=soft" CACHE INTERNAL "asm compiler flags")
set(CMAKE_EXE_LINKER_FLAGS "-nostartfiles -mthumb -mcpu=cortex-m3 -L${linker_scripts_directory} -T${linker_script} --specs=nano.specs" CACHE INTERNAL "linker flags")

target_compile_options(stm32 PRIVATE
    $<$<COMPILE_LANGUAGE:C>:-std=gnu99>
    $<$<COMPILE_LANGUAGE:CXX>:-std=c++1z>
    $<$<CONFIG:DEBUG>:-Og -g>
    $<$<CONFIG:RELEASE>:-Os>
)