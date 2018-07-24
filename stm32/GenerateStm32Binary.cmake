function(generate_stm32_binary target_name)
    add_custom_command(TARGET POST_BUILD ${target_name}
        COMMAND ${arm_eabi_size} --format=berkeley "${target_name}.elf")

    add_custom_target(${target_name}.hex DEPENDS ${target_name} COMMAND ${CMAKE_OBJCOPY} -Oihex ${target_name}.elf ${target_name}.hex)
    file(TO_CMAKE_PATH "${CMAKE_OBJCOPY}" OBJCPY)
    add_custom_target(${target_name}.bin DEPENDS ${target_name} COMMAND ${OBJCPY} -Obinary ${target_name}.elf ${target_name}.bin)
endfunction()