#!/bin/bash

#SBATCH --partition=cpu_medium
#SBATCH --job-name=sr_mono1
#SBATCH --mem-per-cpu=100
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20

python Est_Data.py