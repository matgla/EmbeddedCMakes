function(generate_avr_binary target_name)
    add_custom_command(OUTPUT size
        COMMAND ${avr_size} --format=berkeley "${PROJECT_BINARY_DIR}/src/${target_name}.elf"
        DEPENDS ${target_name})

    add_custom_target(size_t ALL
        DEPENDS size)

    add_custom_target(${target_name}.hex DEPENDS ${target_name} COMMAND ${OBJCPY} -j .text -j .data -Oihex ${target_name}.elf ${target_name}.hex)
    file(TO_CMAKE_PATH "${arm_objcpy}" OBJCPY)
    add_custom_target(${target_name}.bin DEPENDS ${target_name} COMMAND ${OBJCPY} -j .text -j .data -Obin ${target_name}.elf ${target_name}.bin)
endfunction()
