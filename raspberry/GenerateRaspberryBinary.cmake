function(generate_raspberry_binary target_name)
    add_custom_command(OUTPUT ${target_name}_size
        COMMAND ${arm_eabi_size} --format=berkeley "$<TARGET_FILE:${target_name}>"
        DEPENDS ${target_name})

    add_custom_target(${target_name}_size_t ALL
        DEPENDS ${target_name}_size)

    message (STATUS "Setting ${target_name} linker script to: ${linker_script}")
    pico_set_linker_script(${target_name} ${linker_script})
 	pico_add_extra_outputs(${target_name})	
endfunction()
