#!/bin/bash -l
#SBATCH --job-name=install-lammps-setonix-gpu-gpupkg-hipfftsingle
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
dir="lammps-setonix-gpu-hipfftsingle-GPUpkg-rocm543"

module unload cray-libsci
module load fftw/3.3.9
module load rocm/5.4.3
module load craype-accel-amd-gfx90a
export CRAYPE_LINK_TYPE="dynamic"
export MPICH_GPU_SUPPORT_ENABLED=1
#export HIP_PATH=... # defined by rocm module
export HIP_PLATFORM="amd"

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
sed \
    -e 's;CC *=.*;CC = hipcc;g' \
    -e '/CCFLAGS *=/ s/$/ -fopenmp/' \
    -e 's;LINK *=.*;LINK = hipcc;g' \
    -e '/^ *LINKFLAGS *=/ s; $(shell mpicxx --showme:link); -fopenmp;g' \
    -e '/^ *LMP_INC *=/ s; -DLAMMPS_MEMALIGN=64;;g' \
    -e 's;FFT_INC =;FFT_INC = -DFFT_FFTW -DFFT_SINGLE;' \
    -e 's;FFT_LIB =;FFT_LIB = -lfftw3 -lfftw3f;' \
    -e '/MPI_INC *=/ s;$; -I${MPICH_DIR}/include;g' \
    -e '/MPI_LIB *=/ s;$; -L${MPICH_DIR}/lib -lmpi -L${CRAY_MPICH_ROOTDIR}/gtl/lib -lmpi_gtl_hsa;g' \
    MAKE/OPTIONS/Makefile.hip >MAKE/Makefile.setonix_gpu


# build GPU library
#make lib-gpu args="-m cuda -a sm_70 -b"
sed -e 's;HIP_ARCH *= *gfx906;HIP_ARCH = gfx90a;g' \
    ../lib/gpu/Makefile.hip >../lib/gpu/Makefile.hip_setonix
make lib-gpu args="-m hip_setonix -b"

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
make yes-GPU

make -j $SLURM_CPUS_PER_TASK setonix_gpu

echo BUILD-END $( date )
