if (NOT boards_path)
    message(FATAL_ERROR "Path to boards configuration CMake files must be provided via boards_path. Please set board_path variable!")
endif()


set (unknown "Unknown" CACHE STRING "Unknown Tag" FORCE)

##  DEDUCE TARGET ##

set(BOARD ${unknown} CACHE STRING "Board name")
set(MCU ${unknown} CACHE STRING "Target MCU")
set(MCU_FAMILY ${unknown} CACHE STRING "Target MCU family")

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_LIST_DIR}")

set(board_file_glob_expression "${boards_path}/**/${BOARD}.cmake")

message(STATUS "Searching board configuration: ${board_file_glob_expression}")
file(GLOB_RECURSE board_configuration_file "${board_file_glob_expression}")

if (NOT board_configuration_file)
    message(FATAL_ERROR "Can't find configuration file: ${board_file_glob_expression}")
elif()
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


if (${linker_script})
    include (SearchLinkerScript)
    search_linker_script(${vendor} ${mcu} ${linker_scripts_directory} linker_script)
endif ()

## Load SDK ##
if (${vendor} STREQUAL "STM32")
    message (STATUS "Loading STM32 toolchain")
    include(STM32)
endif()

## Export configuration ##

set(mcu "${mcu}" PARENT_SCOPE)
set(arch "${arch}" PARENT_SCOPE)
set(vendor "${vendor}" PARENT_SCOPE)
set(linker_script "${linker_script}" PARENT_SCOPE)