cmake_minimum_required(VERSION 3.9)

add_library(avr INTERFACE)

add_definitions("-DF_CPU=1000000")
set(NO_STDCXX ON CACHE STRING "C++ standard library not exists" FORCE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

add_compile_options("-mmcu=${mcu};-I${CMAKE_CURRENT_SOURCE_DIR}/lib/avr_libstdcpp/avr_libstdcpp/include;-fno-rtti;-fno-use-cxa-atexit;-fno-exceptions;-fno-threadsafe-statics")

target_compile_options(avr INTERFACE
    -fdata-sections
    -ffunction-sections
    $<$<COMPILE_LANGUAGE:C>:-std=gnu99 -Wno-implicit-function-declaration -mmcu=${mcu}>
    $<$<COMPILE_LANGUAGE:CXX>:-std=c++1z -fno-rtti -fno-use-cxa-atexit -fno-exceptions -fno-threadsafe-statics -Wno-register -mmcu=${mcu}>
    $<$<CONFIG:DEBUG>:-O0 -g>
    $<$<CONFIG:RELEASE>:-Os>
)
