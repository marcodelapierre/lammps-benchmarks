#!/bin/bash -l
#SBATCH --job-name=install-lammps-setonix-gpu-kk-hipfftdouble
#SBATCH --account=pawsey0001-gpu
#SBATCH --partition=gpu-dev
#SBATCH --exclusive
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --threads-per-core=1
#SBATCH --gpus-per-node=8
#SBATCH --time=00:30:00
#SBATCH --output=out-%x

release="patch_28Mar2023_update1"
dir="lammps-setonix-gpu-hipfftdouble-rocm543"

module load rocm/5.4.3
module load craype-accel-amd-gfx90a
export CRAYPE_LINK_TYPE="dynamic"
export MPICH_GPU_SUPPORT_ENABLED=1

if [ ! -s ${release}.tar.gz ] ; then
 wget https://github.com/lammps/lammps/archive/${release}.tar.gz
fi

echo BUILD-START $( date )

rm -fr $dir
mkdir -p $dir
cd $dir
tar xzf ../${release}.tar.gz
cd lammps-${release}

cd src
sed -e 's/KOKKOS_DEVICES *=.*/KOKKOS_DEVICES = Hip,OpenMP,Serial\
KOKKOS_ARCH = ZEN3,VEGA90A/' \
    -e 's/CC *=.*/CC = hipcc/g' \
    -e 's/LINK *=.*/LINK = hipcc/g' \
    -e '/^ *CCFLAGS *=/ s/$/ -munsafe-fp-atomics -DKOKKOS_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS/g' \
	-e 's;FFT_INC *=.*;FFT_INC = -DFFT_HIPFFT;g' \
    -e 's;FFT_LIB *=.*;FFT_LIB = -L${ROCM_PATH}/hipfft/lib -lhipfft;g' \
    -e '/MPI_INC *=/ s;$; -I${MPICH_DIR}/include;g' \
    -e '/MPI_LIB *=/ s;$; -L${MPICH_DIR}/lib -lmpi -L${CRAY_MPICH_ROOTDIR}/gtl/lib -lmpi_gtl_hsa;g' \
    MAKE/OPTIONS/Makefile.kokkos_mpi_only >MAKE/Makefile.setonix_gpu

# CUSTOMISE YOUR LIST HERE

#make no-all
make yes-CLASS2
make yes-MANYBODY
make yes-MISC
make yes-EXTRA-DUMP
make yes-EXTRA-FIX

make yes-KSPACE
make yes-MOLECULE
make yes-RIGID
make yes-MOLFILE
make yes-KOKKOS

make -j $SLURM_CPUS_PER_TASK setonix_gpu

echo BUILD-END $( date )
