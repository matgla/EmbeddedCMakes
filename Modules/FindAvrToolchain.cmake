cmake_minimum_required(VERSION 3.6)

if (AVR_TOOLCHAIN_PATH)
    set(avr_toolchain_path "${AVR_TOOLCHAIN_PATH}/bin")
elseif (EXISTS $ENV{AVR_TOOLCHAIN})
    file(TO_CMAKE_PATH $ENV{AVR_TOOLCHAIN} avr_toolchain_path_converted)
    set(avr_toolchain_path "${avr_toolchain_path_converted}/bin")
endif()

message(STATUS "AVR toolchain path: ${avr_toolchain_path}")

if (avr_toolchain_path)
    message(STATUS "AVR toolchain path: ${avr_toolchain_path}")
endif()

set(binary_paths
    "/bin"
    "/usr/bin"
    "${avr_toolchain_path}"
)

find_program(avr_c_compiler
    NAMES
        "avr-gcc"
    PATHS
        ${binary_paths}
)

find_program(avr_cxx_compiler
    NAMES
        "avr-g++"
    PATHS
        ${binary_paths}
)

find_program(avr_objcpy
    NAMES
        "avr-objcopy"
    PATHS
        ${binary_paths}
)

find_program(avr_objdump
    NAMES
        "avr-objdump"
    PATHS
        ${binary_paths}
)

find_program(avr_size
    NAMES
        "avr-size"
    PATHS
        ${binary_paths}
)

message (STATUS "AVR ASM compiler: ${avr_c_compiler}")
message (STATUS "AVR C compiler:   ${avr_c_compiler}")
message (STATUS "AVR CXX compiler: ${avr_cxx_compiler}")
message (STATUS "AVR CXX objcopy:  ${avr_objcpy}")
message (STATUS "AVR CXX objdump:  ${avr_objdump}")

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

set(CMAKE_ASM_COMPILER  ${avr_c_compiler})
set(CMAKE_C_COMPILER    ${avr_c_compiler})
set(CMAKE_CXX_COMPILER  ${avr_cxx_compiler})
set(CMAKE_OBJCOPY       ${avr_objcpy})
set(CMAKE_OBJDUMP       ${avr_objdump})

find_package(PackageHandleStandardArgs)
find_package_handle_standard_args(AvrToolchain DEFAULT_MSG
    avr_c_compiler
    avr_cxx_compiler
    avr_objcpy
    avr_objdump
)