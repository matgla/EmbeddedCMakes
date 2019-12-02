function(generate_stm32_binary target_name)
    add_custom_command(OUTPUT ${target_name}_size
        COMMAND ${arm_eabi_size} --format=berkeley "$<TARGET_FILE:${target_name}>"
        DEPENDS ${target_name})

    add_custom_target(${target_name}_size_t ALL
        DEPENDS ${target_name}_size)

    add_custom_target(${target_name}.hex DEPENDS ${target_name} COMMAND ${CMAKE_OBJCOPY} -Oihex ${target_name}.elf ${target_name}.hex)
    file(TO_CMAKE_PATH "${arm_eabi_objcpy}" OBJCPY)
    add_custom_target(${target_name}.bin DEPENDS ${target_name} COMMAND ${OBJCPY} -Obinary ${target_name}.elf ${target_name}.bin)
endfunction()
