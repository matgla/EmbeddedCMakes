set(CMAKE_SYSTEM_NAME       STM32)
set(CMAKE_SYSTEM_VERSION    1)
set(CMAKE_SYSTEM_PROCESSOR  arm-eabi)

message(STATUS "Extending CMAKE_MODULE_PATH with: ${CMAKE_CURRENT_LIST_DIR}/Modules")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR} "${CMAKE_CURRENT_LIST_DIR}/Modules" CACHE STRING "CMAKE modules")

find_package(ArmToolchain REQUIRED)
find_package(${mcu_family} REQUIRED)

find_package(STLinkUtility)
