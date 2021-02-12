function(generate_stm32_binary target_name)
    add_custom_command(OUTPUT ${target_name}_size
        COMMAND ${arm_eabi_size} --format=berkeley "$<TARGET_FILE:${target_name}>"
        DEPENDS ${target_name})

    add_custom_target(${target_name}_size_t ALL
        DEPENDS ${target_name}_size)

    file(TO_CMAKE_PATH "${arm_eabi_objcpy}" objcopy_exec)

 	pico_add_extra_outputs(${target_name})	
endfunction()
