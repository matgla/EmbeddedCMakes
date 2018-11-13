function(generate_binary target_name)
    if (${vendor} STREQUAL "STM32")
        message("-- Generating ${target_name} binary for: STM32")
        include (stm32/GenerateStm32Binary)
        generate_stm32_binary(${target_name})
    endif ()
endfunction()