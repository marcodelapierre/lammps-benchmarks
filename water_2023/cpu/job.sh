#!/bin/bash -l
#SBATCH --job-name=lmp_benchm
#SBATCH --account=pawsey0012
#SBATCH --partition=work
#SBATCH --time=01:00:00
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128

module load lammps/20210929.3-krpbgzs

lmp="$(which lmp)"
echo using executable $lmp

echo starting lammps at $(date)

srun $lmp \
  -in lammps.inp \
  -screen none -log lammps.out \
  -var run_no 0 -var iseed0 12345 -var iseed1 32109

echo finishing lammps at $(date)

exit
