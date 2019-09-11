cmake_minimum_required(VERSION 3.9)

add_library(avr INTERFACE)

set(NO_STDCXX ON CACHE STRING "C++ standard library not exists" FORCE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

add_compile_options("-mmcu=${mcu};-I${CMAKE_CURRENT_SOURCE_DIR}/lib/avr_libstdcpp/avr_libstdcpp/include;-std=c++2a;-ffunction-sections;-fdata-sections;")

target_compile_options(avr INTERFACE
    -fdata-sections
    -ffunction-sections
    $<$<COMPILE_LANGUAGE:C>:-std=gnu99 -mmcu=${mcu}>
    $<$<COMPILE_LANGUAGE:CXX>:-std=c++2a -mmcu=${mcu}>
    $<$<CONFIG:DEBUG>:-O0 -g>
    $<$<CONFIG:RELEASE>:-Os>
)

set(CMAKE_EXE_LINKER_FLAGS "-mmcu=${mcu} -flto -Wl,--gc-sections -Wl,-Map=mapfile" CACHE INTERNAL "linker flags")
target_link_libraries(avr INTERFACE c m gcc)
