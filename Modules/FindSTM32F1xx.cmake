cmake_minimum_required(VERSION 3.9)

if (DEFINED STM32_LIBRARIES_PATH)
    set(stm32_libraries_root_dir ${STM32_LIBRARIES_PATH})
elseif (EXISTS $ENV{STM32_LIBRARIES_PATH})
    file(TO_CMAKE_PATH $ENV{STM32_LIBRARIES_PATH} stm32_libraries_root_dir)
endif()

if (stm32_libraries_root_dir)
    message(STATUS "STM32 Libraries path: ${stm32_libraries_root_dir}")
else ()
    include(../GitModules)
    find_package(stm32f1xx_stdperiph REQUIRED)
    # clone_module_via_branch("https://github.com/nematix/stm32f10x-stdperiph-lib.git" "stm32f1xx_stdperiph" ${CMAKE_CURRENT_BINARY_DIR} "master")
    # set (stm32_libraries_root_dir "${CMAKE_CURRENT_BINARY_DIR}/stm32f1xx_stdperiph/Libraries")
    # message(FATAL_ERROR "STM32 Libraries can't be found. Please set environment variable: STM32_LIBRARIES_ROOT_DIR or pass path to cmake with -DSTM32_LIBRARIES_PATH")
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
    if ("${mcu_version}" STREQUAL "8" OR ${mcu_version} STREQUAL "b")
        set(mcu_startup_filename_path "startup_stm32f10x_md.s")
        set(mcu_definition "STM32F10X_MD")
    endif ()
endif ()


file(GLOB_RECURSE stm32_startup_file ${stm32_libraries_root_dir}/**/${mcu_startup_filename_path})

string(TOUPPER "${mcu_startup_filename}" mcu_prefix_uppercased)

string (TOUPPER "${mcu_version}" mcu_version_uppercased)

# only gcc version currently supported
list(FILTER stm32_startup_file INCLUDE REGEX ".*TrueSTUDIO.*")

if (NOT EXISTS "${stm32_startup_file}")
    message(FATAL_ERROR "Can't find ${mcu_startup_filename} inside: ${stm32_libraries_root_dir}")
else ()
    message(STATUS "Found startup script: ${stm32_startup_file}")
endif ()

file(GLOB_RECURSE stm32_device_support_sources
    ${stm32_libraries_root_dir}/**/stm32f10x.h
    ${stm32_libraries_root_dir}/**/system_stm32f10x.h
    ${stm32_libraries_root_dir}/**/system_stm32f10x.c
)

file (GLOB_RECURSE stm32_library_sources
    ${stm32_libraries_root_dir}/**/stm32f10x_i2c.h
    ${stm32_libraries_root_dir}/**/stm32f10x_rcc.h
    ${stm32_libraries_root_dir}/**/stm32f10x_dma.h
    ${stm32_libraries_root_dir}/**/misc.h
    ${stm32_libraries_root_dir}/**/stm32f10x_i2c.c
    ${stm32_libraries_root_dir}/**/stm32f10x_rcc.c
    ${stm32_libraries_root_dir}/**/stm32f10x_dma.c
    ${stm32_libraries_root_dir}/**/misc.c
)

list(FILTER stm32_device_support_sources INCLUDE REGEX ".*CMSIS/.*/ST.*")
message("${stm32_device_support_sources}")
list(GET stm32_device_support_sources 0 device_support_element)
list(GET stm32_library_sources 0 library_element)
message("component: ${library_element}")

get_filename_component(stm32_device_support_path ${device_support_element} DIRECTORY)
get_filename_component(stm32_library_path ${library_element} DIRECTORY)

file(GLOB_RECURSE cmsis_core_file
    ${stm32_libraries_root_dir}/**/core_cm3.h
)

if (NOT cmsis_core_file)
    file(GLOB_RECURSE cmsis_core_file
        ${stm32_libraries_root_dir}/**/core_cm3.h.old
    )
    get_filename_component(cmsis_core_file_path ${cmsis_core_file} DIRECTORY)
    message("path ${cmsis_core_file} to ${cmsis_core_file_path}")
    file (RENAME ${cmsis_core_file} ${cmsis_core_file_path}/core_cm3.h)
    set (cmsis_core_file "${cmsis_core_file_path}/core_cm3.h")
endif ()

get_filename_component(cmsis_core_file_path ${cmsis_core_file} DIRECTORY)

file(GLOB sources
    ${stm32_startup_file}
    ${cmsis_core_file}
    ${stm32_device_support_sources}
    ${stm32_library_sources}
)

add_library(stm32)
target_sources(stm32 PRIVATE ${sources})

target_compile_definitions(stm32 PUBLIC "-D${mcu_definition}")
message(STATUS "Added compilation definition: -D${mcu_definition}")

target_sources(stm32 PRIVATE ${sources})

target_include_directories(stm32 PUBLIC
    ${stm32_device_support_path}
    ${cmsis_core_file_path}
    ${stm32_library_path}
)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

set(hal_common_compilation_flags
    "-mthumb;-mno-thumb-interwork;-mfpu=vfp;-mfix-cortex-m3-ldrd;-mcpu=cortex-m3;-mfloat-abi=soft;-fno-builtin;-fdata-sections;-ffunction-sections;")
set(hal_cxx_compilation_flags "${hal_common_compilation_flags};-fno-rtti;-fno-exceptions;-fno-threadsafe-statics;-std=c++2a;-fno-use-cxa-atexit;-Wno-register;" CACHE INTERNAL "HAL CXX compilation flags")
set(hal_c_compilation_flags "${hal_common_compilation_flags};-std=gnu99;-Wno-implicit-function-declaration" CACHE INTERNAL "HAL C compilation flags")

add_library(hal_flags INTERFACE)

target_compile_options(hal_flags INTERFACE
    $<$<COMPILE_LANGUAGE:C>:${hal_c_compilation_flags}>
    $<$<COMPILE_LANGUAGE:CXX>:${hal_cxx_compilation_flags}>
    $<$<COMPILE_LANGUAGE:ASM>:${hal_c_compilation_flags}>
    $<$<CONFIG:DEBUG>:-Og -g>
    $<$<CONFIG:RELEASE>:-Os>
)

set(hal_linker_flags "-mthumb;-mcpu=cortex-m3;-flto;-lstdc++_nano" CACHE INTERNAL "Linker flags")


set(hal_exe_linker_flags "${hal_linker_flags};-L${linker_scripts_directory};-L${PROJECT_SOURCE_DIR};-T${linker_script};-Wl,--gc-sections" CACHE INTERNAL "Linker flags")

if (ENABLE_SEMIHOSTING)
    set(hal_exe_linker_flags ${hal_exe_linker_flags} --specs=nano.specs)
    set(hal_exe_linker_flags ${hal_exe_linker_flags} --specs=rdimon.specs)
else ()
    set(hal_exe_linker_flags ${hal_exe_linker_flags} --specs=nano.specs)
endif ()

target_link_options(hal_flags INTERFACE ${hal_exe_linker_flags})

target_link_libraries(stm32 PUBLIC hal_flags)

add_definitions("-D_CLOCKS_PER_SEC_=1000000")
