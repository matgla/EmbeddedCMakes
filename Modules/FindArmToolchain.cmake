cmake_minimum_required(VERSION 3.6)

# if (ARM_TOOLCHAIN_PATH)
#     set(arm_toolchain_path "${ARM_TOOLCHAIN_PATH}/bin")
# elseif (EXISTS $ENV{ARM_TOOLCHAIN})
#     file(TO_CMAKE_PATH $ENV{ARM_TOOLCHAIN} arm_toolchain_path_converted)
#     set(arm_toolchain_path "${arm_toolchain_path_converted}/bin")
# endif()

# message(STATUS "ARM toolchain path: ${arm_toolchain_path}")

# if (arm_toolchain_path)
#     message(STATUS "ARM toolchain path: ${arm_toolchain_path}")
# endif()

# if (arm_toolchain_path)
#     set(binary_paths "${arm_toolchain_path}")
# else ()
#     set(binary_path "/bin" "/usr/bin")
# endif ()



find_program(arm_eabi_c_compiler
    NAMES
        "arm-none-eabi-gcc"
)

find_program(arm_eabi_cxx_compiler
    NAMES
        "arm-none-eabi-g++"
)

find_program(arm_eabi_objcpy
    NAMES
        "arm-none-eabi-objcopy"
)

find_program(arm_eabi_objdump
    NAMES
        "arm-none-eabi-objdump"
)

find_program(arm_eabi_size
    NAMES
        "arm-none-eabi-size"
)

find_program(arm_eabi_gcc_ar
    NAMES
        "arm-none-eabi-gcc-ar"
)

find_program(arm_eabi_ranlib
    NAMES
        "arm-none-eabi-ranlib"
)

message (STATUS "ARM ASM compiler: ${arm_eabi_c_compiler}")
message (STATUS "ARM C compiler:   ${arm_eabi_c_compiler}")
message (STATUS "ARM CXX compiler: ${arm_eabi_cxx_compiler}")
message (STATUS "ARM CXX objcopy:  ${arm_eabi_objcpy}")
message (STATUS "ARM CXX objdump:  ${arm_eabi_objdump}")
message (STATUS "ARM GCC ar:       ${arm_eabi_gcc_ar}")
message (STATUS "ARM ranlib:       ${arm_eabi_ranlib}")

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

set(CMAKE_ASM_COMPILER          ${arm_eabi_c_compiler})
set(CMAKE_C_COMPILER            ${arm_eabi_c_compiler})
set(CMAKE_CXX_COMPILER          ${arm_eabi_cxx_compiler})
set(CMAKE_OBJCOPY               ${arm_eabi_objcpy} CACHE STRING "Path to objcopy executable")
set(CMAKE_OBJDUMP               ${arm_eabi_objdump})
set(CMAKE_CXX_LINK_EXECUTABLE   ${arm_eabi_cxx_compiler})
set(CMAKE_C_LINK_EXECUTABLE     ${arm_eabi_c_compiler})
set(CMAKE_AR                    ${arm_eabi_gcc_ar})
set(CMAKE_C_COMPILER_AR         ${arm_eabi_gcc_ar})
set(CMAKE_RANLIB                ${arm_eabi_ranlib})
set(CMAKE_C_COMPILER_RANLIB     ${arm_eabi_ranlib})


find_package(PackageHandleStandardArgs)
find_package_handle_standard_args(ArmToolchain DEFAULT_MSG
    arm_eabi_c_compiler
    arm_eabi_cxx_compiler
    arm_eabi_objcpy
    arm_eabi_objdump
    arm_eabi_gcc_ar
    arm_eabi_ranlib
)
