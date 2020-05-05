if (NOT boards_path)
    message(FATAL_ERROR "Path to boards configuration CMake files must be provided via boards_path. Please set board_path variable!")
endif()

set (unknown "Unknown" CACHE STRING "Unknown Tag" FORCE)

##  DEDUCE TARGET ##

set(BOARD ${unknown} CACHE STRING "Board name")
set(MCU ${unknown} CACHE STRING "Target MCU")
set(MCU_FAMILY ${unknown} CACHE STRING "Target MCU family")

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_LIST_DIR}" CACHE STRING "CMAKE modules")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_LIST_DIR}/Modules" CACHE STRING "CMAKE modules")

message("AAAAAAAAAAAAAAAAAA: ${CMAKE_MODULE_PATH}")
if (user_boards_path)
    set(board_file_glob_expression "${user_boards_path}/**/${BOARD}.cmake")
    message(STATUS "Searching board configuration: ${board_file_glob_expression}")
    file(GLOB_RECURSE board_configuration_file "${board_file_glob_expression}")
endif ()

if (board_configuration_file)
    message (STATUS "Found user board configuration: ${board_configuration_file}")
else ()
    set(board_file_glob_expression "${boards_path}/**/${BOARD}.cmake")
    message(STATUS "Searching board configuration: ${board_file_glob_expression}")
    file(GLOB_RECURSE board_configuration_file "${board_file_glob_expression}")
endif ()

if (NOT board_configuration_file)
        message(FATAL_ERROR "Can't find configuration file: ${board_file_glob_expression}")
else ()
    message(STATUS "Found board configuration: ${board_configuration_file}")
    set (device_configuration_file "${board_configuration_file}")
    set (device_configuration_file "${device_configuration_file}" PARENT_SCOPE)
endif()

include (${board_configuration_file})

get_device_info(mcu mcu_family arch vendor)
message(STATUS "MCU:        ${mcu}")
message(STATUS "MCU Family: ${mcu_family}")
message(STATUS "Vendor:     ${vendor}")
message(STATUS "Arch:       ${arch}")

if (${vendor} STREQUAL "STM32")
    get_linker_script(linker_script linker_scripts_directory)
endif()

## Load SDK ##
if (${vendor} STREQUAL "STM32")
    message (STATUS "Loading STM32 toolchain")
    include(STM32)
    include(Modules/Platform/STM32)
    set (path_to_platform_file "Modules/Platform/STM32" CACHE INTERNAL "")
endif()

if (${vendor} STREQUAL "ATMEL")
    message (STATUS "Loading AVR toolchain")
    include(AVR)
    include(Modules/Platform/AVR)
    set (path_to_platform_file "Modules/Platform/AVR" CACHE INTERNAL "")
endif()

## Export configuration ##

get_directory_property(has_parent PARENT_DIRECTORY)
if (has_parent)
    set(mcu "${mcu}" CACHE STRING "target MCU")
    set(arch "${arch}" CACHE STRING "target architecture")
    set(vendor "${vendor}" CACHE STRING "target vendor")
    set(linker_script "${linker_script}" CACHE STRING "target linker script")
endif ()

