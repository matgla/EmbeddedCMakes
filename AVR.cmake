set(CMAKE_SYSTEM_NAME       AVR)
set(CMAKE_SYSTEM_VERSION    1)
set(CMAKE_SYSTEM_PROCESSOR  avr)

message(STATUS "Extending CMAKE_MODULE_PATH with: ${CMAKE_CURRENT_LIST_DIR}/Modules")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_LIST_DIR}/Modules")
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)

find_package(AvrToolchain REQUIRED)
# find_package(${mcu_family} REQUIRED)