#!/bin/bash

#SBATCH --partition=cpu_medium
#SBATCH --job-name=sr_mono1
#SBATCH --tasks=1
#SBATCH --nodes=2
#SBATCH --cpus-per-task=4
#SBATCH --time=2-00:00:00   

python Est_Data.py