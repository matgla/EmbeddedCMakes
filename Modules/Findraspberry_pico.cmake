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

set (CMAKE_CXX_FLAGS_INIT ${CMAKE_CXX_FLAGS_INIT} -std=gnu++20)

set (hal_common_compilation_flags 
-mthumb -march=armv6-m -mcpu=cortex-m0plus
-fno-builtin -fdata-sections -ffunction-sections
)

set (hal_cxx_compilation_flags ${hal_common_compilation_flags} 
    -fno-rtti -fno-exceptions
)

foreach(LANG IN ITEMS C CXX ASM) 
    set (CMAKE_${LANG}_FLAGS ${hal_common_compilation_flags})
    set (CMAKE_${LANG}_LINK_FLAGS "-Wl,--build-id=none")
endforeach()

include (pico_sdk_init) 
pico_sdk_init()

add_library(hal_flags INTERFACE) 

