set(CMAKE_SYSTEM_NAME    	RASPBERRY)
set(CMAKE_SYSTEM_VERSION 	1) 
set(CMAKE_SYSTEM_PROCESSOR 	arm-eabi)

find_package(ArmToolchain REQUIRED)
find_package(${mcu_family} REQUIRED)

