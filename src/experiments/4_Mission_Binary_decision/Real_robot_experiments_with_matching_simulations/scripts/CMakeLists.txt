configure_file( evaluator.in.lua     evaluator.lua)
configure_file( evaluate_threads_hw.in.sh     evaluate_threads_hw.sh   @ONLY)
configure_file( evaluate_threads_simu.in.sh   evaluate_threads_simu.sh @ONLY)

configure_file( run_threads.in.sh    run_threads.sh)
configure_file( run_cluster.in.slurm run_cluster.slurm)
configure_file( replayLogs.in.py     replayLogs.py)

configure_file( drawLine.in.py       drawLine.py)
configure_file( drawLine_main.in.py       drawLine_main.py)
configure_file( drawLine_sup_hw.in.py       drawLine_sup_hw.py)
configure_file( drawLine_sup_simu.in.py     drawLine_sup_simu.py)
