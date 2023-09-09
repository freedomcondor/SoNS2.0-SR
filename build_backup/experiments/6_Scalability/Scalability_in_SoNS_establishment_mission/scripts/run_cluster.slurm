#!/bin/bash

## Resource Request
#SBATCH --job-name=SoNS_exp09           # name of your job, will be shown when running squeue
#SBATCH --output=SoNS_exp09_%A_%a.stdout   # name of the output file, %j will be replaced by the Job ID
#SBATCH --error=SoNS_exp09_%A_%a.stderr    # name of the error file, %j will be replaced by the Job ID
#SBATCH --partition=Epyc7452           # the hardware that you want to run on
#SBATCH --qos=long                    # the queue that you want to run on (short, long)
#SBATCH --ntasks=1                     # the job will launch a single task, set higher for MPI programs
#SBATCH --cpus-per-task=1              # each task will require 1 core on the same machine, set higher for OpenMP programs
#SBATCH --mail-user=weixu.zhu@ulb.be   # your email to receive emails about the state of your job
#SBATCH --mail-type=END,FAIL           # when to send emails, choices are BEGIN, END, FAIL, ARRAY_TASKS

#SBATCH --array=1-750                    # job array

## Module dependencies
#export MODULEPATH=$HOME/Software/modulefiles:$MODULEPATH
module load argos3.mod
module load lua5.3-dev.mod
module load readline-8.1.mod

#srun my_program   # run your program here 
#DATADIR=/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/6_Scalability/Scalability_in_SoNS_establishment_mission/scripts/../data
DATADIR=/home/harry/code-mns2.0/SoNS2.0-SR/build/data_simu
TMPDIR=/tmp/wzhu/SoNS_exp_2_simu_scalability_analyze

# job id
#JOB_ID=1
JOB_ID=$SLURM_ARRAY_TASK_ID

# Repeat
REPEAT=30

#
N_DRONE=$[(JOB_ID+REPEAT-1)/REPEAT]

echo JOB_ID=$JOB_ID
echo REPEAT=$REPEAT
echo N_DRONE=$N_DRONE

# TODO check exist
mkdir -p $DATADIR

mkdir -p $TMPDIR/run$JOB_ID
rm -rf $TMPDIR/run$JOB_ID/*

cd $TMPDIR/run$JOB_ID
mkdir logs
python3 /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/6_Scalability/Scalability_in_SoNS_establishment_mission/scripts/../run.py -r $JOB_ID -l $N_DRONE -v false
lua /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/6_Scalability/Scalability_in_SoNS_establishment_mission/scripts/evaluator.lua $N_DRONE

cd ..
zip -r run$JOB_ID.zip run$JOB_ID
mv run$JOB_ID $DATADIR
mv run$JOB_ID.zip $DATADIR
