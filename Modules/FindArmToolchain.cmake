cmake_minimum_required(VERSION 3.6)

if (ARM_TOOLCHAIN_PATH)
    set(arm_toolchain_path "${ARM_TOOLCHAIN_PATH}/bin")
elseif (EXISTS $ENV{ARM_TOOLCHAIN})
    file(TO_CMAKE_PATH $ENV{ARM_TOOLCHAIN} arm_toolchain_path_converted)
    set(arm_toolchain_path "${arm_toolchain_path_converted}/bin")
endif()

message(STATUS "ARM toolchain path: ${arm_toolchain_path}")

if (arm_toolchain_path)
    message(STATUS "ARM toolchain path: ${arm_toolchain_path}")
endif()

set(binary_paths
    "/bin"
    "/usr/bin"
    "${arm_toolchain_path}"
)

find_program(arm_eabi_c_compiler
    NAMES
        "arm-none-eabi-gcc"
    PATHS
        ${binary_paths}
)

find_program(arm_eabi_cxx_compiler
    NAMES
        "arm-none-eabi-g++"
    PATHS
        ${binary_paths}
)

find_program(arm_eabi_objcpy
    NAMES
        "arm-none-eabi-objcopy"
    PATHS
        ${binary_paths}
)

find_program(arm_eabi_objdump
    NAMES
        "arm-none-eabi-objdump"
    PATHS
        ${binary_paths}
)

find_program(arm_eabi_size
    NAMES
        "arm-none-eabi-size"
    PATHS
        ${binary_paths}
)

message (STATUS "ARM ASM compiler: ${arm_eabi_c_compiler}")
message (STATUS "ARM C compiler:   ${arm_eabi_c_compiler}")
message (STATUS "ARM CXX compiler: ${arm_eabi_cxx_compiler}")
message (STATUS "ARM CXX objcopy:  ${arm_eabi_objcpy}")
message (STATUS "ARM CXX objdump:  ${arm_eabi_objdump}")

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

set(CMAKE_ASM_COMPILER  ${arm_eabi_c_compiler})
set(CMAKE_C_COMPILER    ${arm_eabi_c_compiler})
set(CMAKE_CXX_COMPILER  ${arm_eabi_cxx_compiler})
set(CMAKE_OBJCOPY       ${arm_eabi_objcpy})
set(CMAKE_OBJDUMP       ${arm_eabi_objdump})

find_package(PackageHandleStandardArgs)
find_package_handle_standard_args(ArmToolchain DEFAULT_MSG
    arm_eabi_c_compiler
    arm_eabi_cxx_compiler
    arm_eabi_objcpy
    arm_eabi_objdump
)