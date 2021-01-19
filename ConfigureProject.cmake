function (search_inside board_configuration_directory key out)
    file(GLOB_RECURSE jsons_in_board_configuration "${board_configuration_directory}/*.json")
    foreach(file_path ${jsons_in_board_configuration})
        get_filename_component(file ${file_path} NAME_WE)
        string (TOLOWER ${file} file)
        if (${key} STREQUAL ${file})
            message (STATUS "Found board configuration: ${file_path}")
            set (${out} ${file_path} PARENT_SCOPE)
            return()
    endif ()
endforeach()


endfunction()

if (NOT boards_path)
    message(FATAL_ERROR "Path to boards configuration CMake files must be provided via boards_path. Please set board_path variable!")
endif()

set (unknown "Unknown" CACHE STRING "Unknown Tag" FORCE)

##  DEDUCE TARGET ##

set(BOARD ${unknown} CACHE STRING "Board name")

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR} ${CMAKE_CURRENT_LIST_DIR}/Modules PARENT_SCOPE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR} ${CMAKE_CURRENT_LIST_DIR}/Modules CACHE INTERNAL)


if (NOT soc_config_path)
        message(FATAL_ERROR "SOC config not done")
else ()
    message(STATUS "Found board configuration: ${soc_config_path}")
    set (device_configuration_file "${soc_config_path}")
    get_directory_property(has_parent PARENT_DIRECTORY)
    if (has_parent)
        set (device_configuration_file "${device_configuration_file}" PARENT_SCOPE)
    endif()
endif()

find_package (Python COMPONENTS Interpreter)

execute_process(
    COMMAND ${Python_EXECUTABLE} ${CMAKE_CURRENT_LIST_DIR}/get_device_info.py
    --input=${soc_config_path}
    --output=${CMAKE_CURRENT_BINARY_DIR}/device_configuration
    RESULT_VARIABLE rc
)

set (board_configuration_file ${soc_config_path} CACHE INTERNAL "" FORCE)

set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${CMAKE_CURRENT_LIST_DIR}/get_device_info.py)

if (${rc})
    message (FATAL_ERROR "Can't get device info from: ${board_configuration_directory}")
endif ()

include (${CMAKE_CURRENT_BINARY_DIR}/device_configuration/device.cmake)

set (mcu_family ${family} CACHE INTERNAL "" FORCE)

message(STATUS "MCU:        ${mcu}")
message(STATUS "MCU Family: ${mcu_family}")
message(STATUS "Vendor:     ${vendor}")
message(STATUS "Arch:       ${arch}")

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

