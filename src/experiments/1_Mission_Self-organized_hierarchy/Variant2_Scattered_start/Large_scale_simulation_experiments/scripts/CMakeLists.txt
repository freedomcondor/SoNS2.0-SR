configure_file( evaluator.in.lua     evaluator.lua)
configure_file( evaluate_threads_simu.in.sh     evaluate_threads_simu.sh @ONLY)

configure_file( run_cluster.in.slurm run_cluster.slurm)
configure_file( replayLogs.in.py     replayLogs.py)

configure_file( drawLine.in.py       drawLine.py)
configure_file( drawLine_sup_simu.in.py       drawLine_sup_simu.py)