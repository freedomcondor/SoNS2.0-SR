#argos file is generated by run.py
configure_file( run.in.py        run.py)
configure_file( sons_template.in.argos
                sons_template.argos)
configure_file( common.in.lua       common.lua)

configure_file( morphologiesGenerator.in.lua 
                morphologiesGenerator.lua)
                
add_subdirectory(scripts)

configure_file( run_debug_choose_gate.in.py        run_debug_choose_gate.py)
configure_file( morphologiesGenerator_choose_gate.in.lua 
                morphologiesGenerator_choose_gate.lua)

configure_file( run_debug_forward_again.in.py        run_debug_forward_again.py)
configure_file( morphologiesGenerator_forward_again.in.lua 
                morphologiesGenerator_forward_again.lua)

configure_file( run_debug_reference_bump_test.in.py  run_debug_reference_bump_test.py)
configure_file( morphologiesGenerator_bump_test.in.lua 
                morphologiesGenerator_bump_test.lua)

configure_file( run_debug_structure3.in.py        run_debug_structure3.py)