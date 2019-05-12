function (execute_command command_to_execute)
    message (STATUS "Executing: ${command_to_execute}")
    find_package(Git QUIET)
    if (NOT GIT_FOUND)
        message (FATAL_ERROR "Can't find git")
    endif ()

    string(REPLACE " " ";" command_to_execute "${command_to_execute}")

    set (command_ git submodule foreach git checkout master)
    execute_process(
        COMMAND
            ${command_to_execute}
        WORKING_DIRECTORY
            ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        RESULT_VARIABLE result
    )

    if (NOT result EQUAL "0")
        message ("Failure: ${OUTPUT_VARIABLE}")
        message (FATAL_ERROR "Failure: ${ERROR_VARIABLE}")
    endif ()
endfunction()

function (fetch_module module_name)
    message (STATUS "Update module: ${module_name}")
    find_package(Git QUIET)
    if (NOT GIT_FOUND)
        message (FATAL_ERROR "Can't find git")
    endif ()

    if (NOT TARGET ${module_name})
        execute_process(
            COMMAND
                git submodule update --init -- lib/${module_name}
            WORKING_DIRECTORY
                ${CMAKE_CURRENT_SOURCE_DIR}
        )
        add_subdirectory(${module_name})
    endif ()
endfunction()