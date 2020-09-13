cmake_minimum_required(VERSION 3.9)

if (NOT stm32_libraries_root_dir)
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

    set (stm32_libraries_root_dir ${stm32f4_hal_SOURCE_DIR} CACHE INTERNAL "" FORCE)
endif ()

string (TOLOWER "${mcu}" mcu)

set (cmsis_directory "${stm32_libraries_root_dir}/Drivers/CMSIS")
set (stm32f4_cmsis_directory "${cmsis_directory}/Device/ST/STM32F4xx/")

set (startup_files_directory "${stm32_libraries_root_dir}/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc")

string(REGEX MATCH "stm32f4.."
    mcu_startup_filename ${mcu})

set(mcu_startup_filename_path "startup_${mcu_startup_filename}xx.s")

file(GLOB_RECURSE stm32_startup_file ${startup_files_directory}/${mcu_startup_filename_path})

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
    ${stm32_driver_directory}/Src/*.c
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

target_compile_definitions(stm32 PUBLIC -D${mcu_prefix_uppercased}xx)

add_definitions(-D_CLOCKS_PER_SEC_=1000000 -D${mcu_prefix_uppercased}xx)
