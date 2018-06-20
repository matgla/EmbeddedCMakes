set (unknown "Unknown" CACHE STRING "Unknown Tag" FORCE)

##  DEDUCE TARGET ##

set(BOARD ${unknown} CACHE STRING "Board name")
set(MCU ${unknown} CACHE STRING "Target MCU")
set(MCU_FAMILY ${unknown} CACHE STRING "Target MCU family")

if (NOT ${BOARD} STREQUAL ${unknown})
    include (cmake/BoardToMcu.cmake)
    message ("-- Board set to: ${BOARD}. Deducing hardware...")
    board_to_mcu(${BOARD} mcu)
endif ()

if ((NOT mcu) AND (NOT ${MCU} STREQUAL ${unknown}))
    set(mcu ${MCU})    
elseif (NOT mcu)
    message (FATAL_ERROR "Can't deduce MCU family!")
endif ()

message ("-- MCU: ${mcu}")
include (cmake/McuToMcuFamily.cmake)
message ("-- Deducing MCU family...")
mcu_to_mcufamily(${mcu} mcu_family)

if ((NOT mcu_family) AND (NOT ${MCU_FAMILY} STREQUAL ${unknown}))
    set(mcu_family ${MCU_FAMILY})
elseif (NOT mcu_family)
    message (FATAL_ERROR "Can't deduce architecture!")
endif ()

message ("-- MCU family: ${mcu_family}")
include (cmake/McuFamilyToArch.cmake)
message ("-- Deducing architecture...")
mcufamily_to_arch(${mcu_family} arch vendor)
message ("-- Arch: ${arch}")

## LOAD TOOLSET ##

if (${vendor} STREQUAL "STM32")
    include(cmake/stm32/McuToClass.cmake)
    mcu_to_class(${mcu} device_class)
    message("-- STM32 device class: ${device_class}")
    include(cmake/STM32.cmake)
endif()