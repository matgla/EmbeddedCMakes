function(generate_avr_binary target_name)
    add_custom_target(size_t
        ALL
        DEPENDS size)

    add_custom_command(OUTPUT size
        COMMAND ${avr_size} --format=berkeley "${PROJECT_BINARY_DIR}/src/${target_name}.elf"
        DEPENDS always_rebuild)

    add_custom_command(
        OUTPUT always_rebuild
        COMMAND cmake -E echo
    )

    file(TO_CMAKE_PATH "${avr_objcpy}" OBJCPY)
    message(STATUS "Binary(hex) command: ${target_name}.hex DEPENDS ${target_name} COMMAND ${OBJCPY} -j .text -j .data -Oihex ${target_name}.elf ${target_name}.hex")
    add_custom_target(${target_name}.hex DEPENDS ${target_name} COMMAND ${OBJCPY} -j .text -j .data -Oihex ${target_name}.elf ${target_name}.hex)
endfunction()
