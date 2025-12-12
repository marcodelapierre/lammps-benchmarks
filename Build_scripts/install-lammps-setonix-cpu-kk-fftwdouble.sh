#!/bin/bash -l
#SBATCH --job-name=install-lammps-setonix-cpu-kk-fftwdouble
#SBATCH --account=pawsey0001
#SBATCH --partition=debug
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --mem=115G
#SBATCH --time=01:00:00
#SBATCH --output=out-%x

release="patch_30Jul2021"
dir="lammps-viscous-setonix-kk-fftwdouble-gnu-30jul21-ph2cpu"

if [ ! -s ${release}.tar.gz ] ; then
 wget https://github.com/lammps/lammps/archive/${release}.tar.gz
fi

echo BUILD-START $( date )

rm -fr $dir
mkdir -p $dir
cd $dir
tar xzf ../${release}.tar.gz
cd lammps-${release}/src

module unload cray-libsci
module load fftw/3.3.9

export CRAYPE_LINK_TYPE='dynamic'

export KOKKOS_DEVICES="Serial,OpenMP"
export KOKKOS_ARCH="ZEN3"

sed -e '/^ *CC *=/ s/=.*/= CC/' \
    -e '/^ *LINK *=/ s/=.*/= CC/' \
    -e 's/FFT_INC =/FFT_INC = -DFFT_FFTW -DFFT_DOUBLE/' \
    -e 's/FFT_LIB =/FFT_LIB = -lfftw3 -lfftw3f/' \
    MAKE/OPTIONS/Makefile.g++_mpich >MAKE/Makefile.setonix


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
make yes-INTEL

make -j 8 setonix

echo BUILD-END $( date )
