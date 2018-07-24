cmake_minimum_required(VERSION 3.9)

if (DEFINED $ENV{STM32_LIBRARIES_ROOT_DIR})
    file(TO_CMAKE_PATH $ENV{STM32_LIBRARIES_ROOT_DIR} stm32_libraries_root_dir_converted)
    set(stm32_libraries_root_dir ${stm32_library_root_dir_converted})
elseif (DEFINED STM32_LIBRARIES_PATH)
    set(stm32_libraries_root_dir ${STM32_LIBRARIES_PATH})
endif()

if (stm32_libraries_root_dir)
    message("-- STM32 Libraries path: ${stm32_libraries_root_dir}")
else ()
    message(FATAL_ERROR "STM32 Libraries can't be found. Please set environment variable: STM32_LIBRARIES_ROOT_DIR or pass path to cmake with -DSTM32_LIBRARIES_PATH")
endif ()

file(GLOB_RECURSE stm32_startup_file ${stm32_libraries_root_dir}/**/startup_stm32f10x_${device_class}.s)

# only gcc version currently supported
list(FILTER stm32_startup_file INCLUDE REGEX ".*gcc_ride.*")

if (NOT EXISTS "${stm32_startup_file}")
    message(FATAL_ERROR "Can't find gcc_ride7/startup_stm32f10x_${device_class}.s under: ${stm32_libraries_root_dir}")
endif ()

file(GLOB_RECURSE stm32_some_sources_files ${stm32_libraries_root_dir}/**/stm32f10x_adc.c)
file(GLOB_RECURSE stm32_some_includes_files ${stm32_libraries_root_dir}/**/stm32f10x_adc.h)

if (NOT EXISTS "${stm32_some_sources_files}")
    message(FATAL_ERROR "Can't find sources")
endif ()

if (NOT EXISTS "${stm32_some_includes_files}")
    message(FATAL_ERROR "Can't find includes")
endif ()

get_filename_component(stm32_sources_path ${stm32_some_sources_files} DIRECTORY)
get_filename_component(stm32_includes_path ${stm32_some_includes_files} DIRECTORY)

file(GLOB_RECURSE stm32_device_support_sources  
    ${stm32_libraries_root_dir}/**/stm32f10x.h
    ${stm32_libraries_root_dir}/**/system_stm32f10x.h
    ${stm32_libraries_root_dir}/**/system_stm32f10x.c
)

list(FILTER stm32_device_support_sources INCLUDE REGEX ".*DeviceSupport.*STM32F10x.*")
list(GET stm32_device_support_sources 0 device_support_element)

get_filename_component(stm32_device_support_path ${device_support_element} DIRECTORY)

file(GLOB_RECURSE cmsis_core_file  
    ${stm32_libraries_root_dir}/**/core_cm3.h
)

get_filename_component(cmsis_core_file_path ${cmsis_core_file} DIRECTORY)

file(GLOB_RECURSE stm32_conf_file  
    ${stm32_libraries_root_dir}/**/stm32f10x_conf.h
)
list(FILTER stm32_conf_file INCLUDE REGEX ".*STM32F10x.*Template.*")
get_filename_component(stm32_conf_file_path ${stm32_conf_file} DIRECTORY)

file(GLOB sources 
    ${stm32_sources_path}/*.c 
    ${stm32_includes_path}/*.h 
    ${stm32_startup_file}
    ${cmsis_core_file}
    ${stm32_conf_file}
    ${stm32_device_support_sources}
)

string(TOUPPER ${device_class} device_class_uppercased)
add_definitions(-DSTM32F10X_${device_class_uppercased} -DUSE_STDPERIPH_DRIVER)

add_library(stm32 ${sources})

target_include_directories(stm32 PUBLIC 
    ${stm32_device_support_path}
    ${stm32_includes_path}
    ${cmsis_core_file_path}
    ${stm32_conf_file_path}
)

target_compile_options(stm32 PRIVATE
    $<$<COMPILE_LANGUAGE:C>:-std=gnu99>
    $<$<COMPILE_LANGUAGE:CXX>:-std=c++1z>
    $<$<CONFIG:DEBUG>:-Og -g>
    $<$<CONFIG:RELEASE>:-Os>
)

include(../AddTargetCompileOptions.cmake)
add_target_compile_options(stm32)

set_target_properties(stm32 PROPERTIES LINK_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--gc-sections")
set_property(TARGET stm32 PROPERTY INTERPROCEDURAL_OPTIMIZATION true)