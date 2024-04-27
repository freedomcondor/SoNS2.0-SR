## simulation
configure_file( sons_template.in.argos
                sons_template.argos)

configure_file( run.in.py
                run.py)

configure_file( common.in.lua      simu/common.lua)

## scripts
add_subdirectory(scripts)