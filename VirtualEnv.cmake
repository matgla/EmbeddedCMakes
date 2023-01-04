# Copyright 2022 Mateusz Stadnik

# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.

function (setup_virtualenv venv_name requirements working_directory)
    find_package(PythonInterp REQUIRED)
    find_program(venv_exec virtualenv)
    if (NOT venv_exec)
        message(FATAL_ERROR, "Virtualenv not found in PATH")
    endif ()

    add_custom_command(
        OUTPUT venv
        COMMAND ${venv_exec} ${working_directory}/${venv_name}
    )

    if (EXISTS ${working_directory}/${venv_name}/bin/pip)
        set (pip_exec ${working_directory}/${venv_name}/bin/pip)
    elseif (EXISTS ${working_directory}/${venv_name}/Scripts/pip.exe)
        set (pip_exec ${working_directory}/${venv_name}/Scripts/pip.exe)
    else ()
        message (FATAL_ERROR "PIP not found under: ${working_directory}/${venv_name}")
    endif ()

    add_custom_command(
        OUTPUT ${working_directory}/venv.stamp
        DEPENDS venv ${requirements}
        COMMAND ${pip_exec} install -r ${requirements} --upgrade -q -q -q
    )

    if (EXISTS ${working_directory}/${venv_name}/bin/python3)
        set (${venv_name}_python_executable ${working_directory}/${venv_name}/bin/python3 CACHE INTERNAL "" FORCE)
    elseif (EXISTS ${working_directory}/${venv_name}/Scripts/python.exe)
        set (${venv_name}_python_executable ${working_directory}/${venv_name}/Scripts/python.exe CACHE INTERNAL "" FORCE)
    else ()
        message (FATAL_ERROR "Python not found under: ${working_directory}/${venv_name}")
    endif ()
endfunction ()