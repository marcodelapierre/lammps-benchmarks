#!/bin/bash -l
#SBATCH --job-name=lmp_benchm
#SBATCH --account=pawsey0001-gpu
#SBATCH --partition=gpu-dev
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=1
#SBATCH --threads-per-core=1
#SBATCH --gpus-per-node=8
#SBATCH --time=00:30:00

module load rocm/5.4.3
module load craype-accel-amd-gfx90a
export MPICH_GPU_SUPPORT_ENABLED=1

lmp="/software/projects/pawsey0001/mdelapierre/viscous/lammps-setonix-gpu-hipfftsingle-GPUpkg-rocm543/lammps-patch_28Mar2023_update1/src/lmp_setonix_gpu"

echo starting lammps at $(date)

srun \
    $lmp -sf gpu -pk gpu $SLURM_GPUS_PER_NODE \
    -screen none -in lammps.inp -log lammps.out \
	-var run_no 0 \
	-var iseed0 12345 \
	-var iseed1 32109

echo finishing lammps at $(date)

exit
