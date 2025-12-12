#!/bin/bash
#SBATCH --job-name=lmp_benchm
#SBATCH --account=pawsey0012
#SBATCH --partition=workq
#SBATCH --time=02:00:00
#SBATCH --ntasks-per-node=24
#SBATCH --nodes=1
#SBATCH --no-requeue
#SBATCH --export=NONE

module swap PrgEnv-cray/6.0.4 PrgEnv-intel
module unload cray-libsci

lmp_bin="/group/pawsey0001/mdelapierre/benchmarks/lammps_feb19/magnus/dir_magnus/lammps-patch_8Feb2019/src/lmp_magnus"
echo using executable $lmp_bin

echo starting lammps at $(date)

srun --export=all $lmp_bin -screen none -in lammps.inp -log lammps.out \
	-var run_no 0 \
	-var iseed0 12345 \
	-var iseed1 32109

echo finishing lammps at $(date)

exit
