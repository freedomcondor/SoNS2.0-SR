configure_file( evaluator.in.lua     evaluator.lua)

configure_file( run_cluster.in.slurm run_cluster.slurm)
configure_file( run_threads.in.sh    run_threads.sh   @ONLY)
configure_file( eva_threads.in.sh    eva_threads.sh   @ONLY)

configure_file( replayLogs.in.py     replayLogs.py)

configure_file( drawLine.in.py           drawLine.py)
configure_file( drawLine_main.in.py      drawLine_main.py)
configure_file( drawLine_sup_simu.in.py  drawLine_sup_simu.py)

set(CMAKE_MNS3_BINARY_DIR /home/harry/code/mns3.0/build)
configure_file( replay.in.py              replay.py )
configure_file( replayer_template.in.argos  replayer_template.argos )