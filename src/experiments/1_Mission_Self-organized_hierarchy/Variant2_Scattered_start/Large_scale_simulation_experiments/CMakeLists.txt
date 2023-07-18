## simulation
configure_file( sons_template.in.argos
                sons_template.argos)

configure_file( run.in.py
                run.py)

## scripts
add_subdirectory(scripts)

## hardware 
configure_file( common.in.lua      simu/common.lua)
configure_file( morphology.lua     simu/morphology.lua     COPYONLY)
configure_file( morphologiesGenerator.in.lua     simu/morphologiesGenerator.lua     COPYONLY)

file(GLOB MY_PUBLIC_HEADERS ${CMAKE_SOURCE_DIR}/core/api/*)
file(COPY ${MY_PUBLIC_HEADERS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/simu)
file(GLOB MY_PUBLIC_HEADERS ${CMAKE_SOURCE_DIR}/core/utils/*)
file(COPY ${MY_PUBLIC_HEADERS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/simu)
file(GLOB MY_PUBLIC_HEADERS ${CMAKE_SOURCE_DIR}/core/sons/*)
file(COPY ${MY_PUBLIC_HEADERS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/simu)