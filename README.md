## Lammps-Benchmarks

Simple benchmarks for Lammps, CPU and GPU, from Pawsey times.

Two models available:
- Argon: standard one from Lammps repo and tutorials, easy to compare with benchmarks available publicly, but only testing one force-field type (Lennard-Jones)
  - Inputs are adapted from the [LAMMPS source](https://github.com/lammps/lammps), `examples/UNITS/`
- Water: more comprehensive model, with multiple force-field types (including Coulomb, that uses the FFT package)
