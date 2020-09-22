cmake_minimum_required(VERSION 3.9)

include(FetchContent)

FetchContent_Declare(
    stm32f4_hal
    GIT_REPOSITORY https://github.com/STMicroelectronics/STM32CubeF4.git
    GIT_TAG        v1.25.1
    GIT_PROGRESS   TRUE
)

FetchContent_GetProperties(stm32f4_hal
    POPULATED stm32f4_hal_POPULATED
)

if (NOT stm32f4_hal_POPULATED)
    FetchContent_Populate(stm32f4_hal)

    FetchContent_GetProperties(stm32f4_hal
        POPULATED stm32f4_hal_POPULATED
    )
endif ()

set (stm32_libraries_root_dir ${stm32f4_hal_SOURCE_DIR})

string (TOLOWER "${mcu}" mcu)

set (cmsis_directory "${stm32_libraries_root_dir}/Drivers/CMSIS")
set (stm32f4_cmsis_directory "${cmsis_directory}/Device/ST/STM32F4xx/")

set (startup_files_directory "${stm32_libraries_root_dir}/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc")

# TODO: How to select correct version?
string(REGEX MATCH "stm32f4...."
    mcu_name_with_variant ${mcu})

string(REGEX MATCH "stm32f4.."
    mcu_startup_filename ${mcu})

string(REGEX MATCH "..$"
    mcu_variant ${mcu_name_with_variant})

set(mcu_startup_filename_path "startup_${mcu_startup_filename}*.s")

file(GLOB_RECURSE stm32_startup_files ${startup_files_directory}/${mcu_startup_filename_path})


set (selected_variant "")
foreach(startup_file ${stm32_startup_files})
    get_filename_component(filename_without_extension ${startup_file} NAME_WE)
    string(REGEX MATCH "..$"
        file_variant ${filename_without_extension})

    string(REGEX MATCH ".$"
        mcu_variant_minor ${mcu_variant})

    string(REGEX MATCH "^."
        mcu_variant_major ${mcu_variant})

    string(REGEX MATCH ".$"
        file_variant_minor ${file_variant})

    string(REGEX MATCH "^."
        file_variant_major ${file_variant})

    if (${file_variant_major} STREQUAL ${mcu_variant_major}
        AND ${file_variant_minor} STREQUAL ${mcu_variant_minor})
        set (selected_variant ${file_variant})
        set (stm32_startup_file ${startup_file})
        break()
    endif ()

    if (${file_variant_major} STREQUAL ${mcu_variant_major}
        AND ${file_variant_minor} STREQUAL "x")
        set (selected_variant ${file_variant})
        set (stm32_startup_file ${startup_file})
        break()
    endif ()

    if (${file_variant_major} STREQUAL "x"
        AND ${file_variant_minor} STREQUAL "x")
        set (selected_variant ${file_variant})
        set (stm32_startup_file ${startup_file})
        break()
    endif ()

    if (${file_variant_major} STREQUAL "x"
        AND ${file_variant_minor} STREQUAL ${mcu_variant_minor})
        set (selected_variant ${file_variant})
        set (stm32_startup_file ${startup_file})
        break()
    endif ()
endforeach()

if (NOT EXISTS "${stm32_startup_file}")
    message(FATAL_ERROR "Can't find ${mcu_startup_filename} inside: ${stm32_libraries_root_dir}")
else ()
    message(STATUS "Found startup script: ${stm32_startup_file}")
endif ()

set (stm32_cmsis_sources
    ${stm32f4_cmsis_directory}/Include/stm32f4xx.h
    ${stm32f4_cmsis_directory}/Include/system_stm32f4xx.h
    ${stm32f4_cmsis_directory}/Source/Templates/system_stm32f4xx.c
    ${stm32_startup_file}
)

set (stm32_driver_directory "${stm32_libraries_root_dir}/Drivers/STM32F4xx_HAL_Driver/")

file (GLOB stm32_driver_sources
    ${stm32_driver_directory}/Inc/*.h
    ${stm32_driver_directory}/Src/stm32f4xx_hal_rcc.c
    ${stm32_driver_directory}/Src/stm32f4xx_hal_gpio.c
    ${stm32_driver_directory}/Src/stm32f4xx_hal_usart.c
    ${stm32_driver_directory}/Src/stm32f4xx_hal.c
    ${stm32_driver_directory}/Src/stm32f4xx_hal_nvic.c
    ${stm32_driver_directory}/Src/stm32f4xx_hal_cortex.c
    ${stm32_driver_directory}/Src/stm32f4xx_hal_pwr_ex.c
    ${stm32_driver_directory}/Src/stm32f4xx_hal_uart.c
)

file(GLOB_RECURSE cmsis_core_file
    ${cmsis_directory}/Include/core_cm4.h
)

add_library(stm32)
target_sources(stm32
    PRIVATE
        ${cmsis_core_file}
        ${stm32_cmsis_sources}
        ${stm32_driver_sources}
)

target_include_directories(stm32 PUBLIC
    ${stm32_driver_directory}/Inc/
    ${cmsis_directory}/Include/
    ${stm32f4_cmsis_directory}/Include/
)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

set(hal_common_compilation_flags
    "-mthumb;-mno-thumb-interwork;-mfpu=vfp;-mfloat-abi=soft;-mcpu=cortex-m4;-fno-builtin;-fdata-sections;-ffunction-sections;")
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

set(hal_linker_flags "-mthumb;-mcpu=cortex-m4;-flto;-lstdc++_nano" CACHE INTERNAL "Linker flags")


set(hal_exe_linker_flags "${hal_linker_flags};-L${linker_scripts_directory};-L${PROJECT_SOURCE_DIR};-T${linker_script};-Wl,--gc-sections" CACHE INTERNAL "Linker flags")

if (ENABLE_SEMIHOSTING)
    set(hal_exe_linker_flags ${hal_exe_linker_flags} --specs=nano.specs)
    set(hal_exe_linker_flags ${hal_exe_linker_flags} --specs=rdimon.specs)
else ()
    set(hal_exe_linker_flags ${hal_exe_linker_flags} --specs=nano.specs)
endif ()

target_link_options(hal_flags INTERFACE ${hal_exe_linker_flags})

target_link_libraries(stm32 PUBLIC hal_flags)

string(TOUPPER "${mcu_startup_filename}" mcu_prefix_uppercased)

string(REGEX MATCH ".$"
    selected_variant_minor ${selected_variant})

string(REGEX MATCH "^."
    selected_variant_major ${selected_variant})

if (NOT ${selected_variant_minor} STREQUAL "x")
    string (TOUPPER ${selected_variant_minor} selected_variant_minor)
endif ()

if (NOT ${selected_variant_major} STREQUAL "x")
    string (TOUPPER ${selected_variant_major} selected_variant_major)
endif ()

set (mcu_definition ${mcu_prefix_uppercased}${selected_variant_major}${selected_variant_minor})

target_compile_definitions(stm32 PUBLIC -D${mcu_definition})

add_definitions(-D_CLOCKS_PER_SEC_=1000000 -D${mcu_definition})
