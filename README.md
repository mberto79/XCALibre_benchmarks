# XCALibre_benchmarks

This repository will host benchmarks for the Julia package `XCALibre.jl` and it will be continuously updated (should be considered as work in progress).

## Usage and notes

The various benchmarks will be organised in folders, it will be assumed/required for any scripts included to be launched within each individual folder (all paths in the scripts will assume this). The following additional observations should be considered:

* Benchmark cases for `XCALibre.jl` will include a Project.toml file. Before running benchmarks, the environment should be activated (in package mode `activate .`)
* For benchmarks involving OpenFOAM, the user should ensure that OpenFOAM is installed in their system. For information on installing OpenFOAM visit their [website](https://openfoam.org/)
* For GPU tests, only NVIDIA gpus are currently supporter/set up
* Only bash scripts are provided, which should run on most linux distributions. Windows/Mac specific scripts are not currently provided/supported
* Some modifications of the the scripts provided here may be required e.g. the number of cores used for CPU multithread tests is currently hard-coded for 8 CPUs
* Mesh files are not kept in this repository but will be automatically downloaded from `aerofluids.org`
* If you encounter any problems please report it by opening an issue on this repository (not in the main `XCALibre.jl` repository)

## CFD code benchmarks can be challenging

When comparing CFD codes it can be quite challenging to ensure that the codes are set up in an "equivalent" manner. Not only codes can differ in terms of internal implementation and features, but multiple aspects can make "like-for-like" comparisons quite challenging e.g. linear solvers, preconditioners, residual definitions, etc. Whilst every effort will be made to ensure that tests are "comparable", discrepancies may exists. In part, this challenge motived the creation of this repository, so that any comparisons made can be publicly and openly scrutinised. In this spirit, please report any aspect of our testing/benchmarking methodology that may be incorrect or questionable. Of course, suggestions to improve our methodology are always welcome.