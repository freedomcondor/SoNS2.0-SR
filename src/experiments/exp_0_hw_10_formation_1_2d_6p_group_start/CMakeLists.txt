## simulation
configure_file( sons_template.in.argos
                sons_template.argoss)

configure_file( generate_hw_argos.in.py
                generate_hw_argos.py)

configure_file( run.in.py
                run.py)

## scripts
add_subdirectory(scripts)

## hardware 
configure_file( common.in.lua      hw/common.lua)
configure_file( common.in.lua      simu/common.lua)
configure_file( morphology.lua     hw/morphology.lua     COPYONLY)
configure_file( morphology.lua     simu/morphology.lua     COPYONLY)

file(GLOB MY_PUBLIC_HEADERS ${CMAKE_SOURCE_DIR}/core/api/*)
file(COPY ${MY_PUBLIC_HEADERS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/hw)
file(COPY ${MY_PUBLIC_HEADERS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/simu)
file(GLOB MY_PUBLIC_HEADERS ${CMAKE_SOURCE_DIR}/core/utils/*)
file(COPY ${MY_PUBLIC_HEADERS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/hw)
file(COPY ${MY_PUBLIC_HEADERS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/simu)
file(GLOB MY_PUBLIC_HEADERS ${CMAKE_SOURCE_DIR}/core/sons/*)
file(COPY ${MY_PUBLIC_HEADERS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/hw)
file(COPY ${MY_PUBLIC_HEADERS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/simu)