cmake_minimum_required(VERSION 3.9)

if (DEFINED PICO_SDK_PATH)
	set (pico_sdk_path ${PICO_SDK_PATH})
elseif (EXISTS $ENV{PICO_SDK_PATH})
	file (TO_CMAKE_PATH $ENV{PICO_SDK_PATH} pico_sdk_path)
else () 
	include (FetchContent) 
	message (STATUS "Prepare PICO SDK to fetch")
	FetchContent_Declare(
		pico_sdk 
		GIT_REPOSITORY https://github.com/raspberrypi/pico-sdk.git
		GIT_TAG        1.0.1
		GIT_PROGRESS   TRUE
		USES_TERMINAL_DOWNLOAD TRUE
		FETCHCONTENT_QUIET FALSE
		GIT_SUBMODULES ""
	)

	FetchContent_GetProperties(pico_sdk 
		POPULATED pico_sdk_POPULATED
	)

	set(FETCHCONTENT_QUIET FALSE)
	if (NOT pico_sdk_POPULATED)
		message (STATUS "Fetch PICO SDK")
		FetchContent_Populate(
			pico_sdk
		)
		FetchContent_GetProperties(pico_sdk 
			POPULATED pico_sdk_POPULATED 
		)
	endif()
endif ()

set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${pico_sdk_SOURCE_DIR})

#include (cmake/preload/toolchains/pico_arm_gcc)

#set (CMAKE_CXX_FLAGS_INIT ${CMAKE_CXX_FLAGS_INIT} -std=gnu++20)

set (hal_common_compilation_flags 
"-mthumb -march=armv6-m -mcpu=cortex-m0plus -fno-builtin -fdata-sections -ffunction-sections"
)

set (hal_cxx_compilation_flags "${hal_common_compilation_flags} -fno-rtti -fno-exceptions"
)

set (CMAKE_CXX_FLAGS ${hal_cxx_compilation_flags} CACHE STRING "CXX Flags" FORCE)
set (CMAKE_C_FLAGS ${hal_common_compilation_flags} CACHE STRING "C Flags" FORCE)
set (CMAKE_ASM_FLAGS ${hal_common_compilation_flags} CACHE STRING "ASM Flags" FORCE) 

include (pico_sdk_init) 
pico_sdk_init()

add_library(hal_flags INTERFACE) 

set (hal_linker_flags "-mthumb -mcpu=cortex-m0plus -flto -lstdc++_nano" CACHE INTERNAL "Linker flags")

set(hal_exe_linker_flags
    "${hal_linker_flags} -L${linker_scripts_directory} -L${PROJECT_SOURCE_DIR} -L${board_configuration_path} -T${linker_script} -Wl,--gc-sections" CACHE INTERNAL "Linker flags")

target_link_options(hal_flags INTERFACE ${hal_exe_linker_flags})

target_link_libraries(pico_standard_link INTERFACE hal_flags)

#set (CMAKE_EXE_LINKER_FLAGS ${hal_exe_linker_flags} CACHE STRING "Linker flags" FORCE)

