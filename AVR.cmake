set(CMAKE_SYSTEM_NAME       AVR CACHE STRING "CMAKE System name" FORCE)
set(CMAKE_SYSTEM_VERSION    1 CACHE STRING "CMAKE System version" FORCE)
set(CMAKE_SYSTEM_PROCESSOR  avr CACHE STRING "CMAKE System processor" FORCE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_LIST_DIR}/Modules" CACHE STRING "CMAKE modules")

find_package(AvrToolchain REQUIRED)
find_package(${mcu_family} REQUIRED)

message("System name: ${CMAKE_SYSTEM_NAME}")