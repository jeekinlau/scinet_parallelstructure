# README

This is a README for running code to perform parallelstructure on the SCINET compute cluster ceres.

## Getting Started
These instructions will give you a outline of how to use two main scripts to execute parallelstructure on multiple compute nodes. Parallelstructure is an R package that allows for running many instances of STRUCTURE on a cluster.

## Prerequisites

### Parallelstructure installation
login to ceres and open an R instance

```
# module load in on ceres STRUCTURE and R
ml structure/2.3.4 
ml r/4.3.1

# open R in the terminal
R 

# install parallelstructure
install.packages("ParallelStructure", repos="http://R-Forge.R-project.org")
```

## General outline of scripts

Two main scripts. One slurm job script and one R script.
The slurm job script is used to submit a master R script to the cluster and this R Script will create the other R scripts and other slurm job scripts to parallelize parallelstructure on multiple nodes. The outputs should all be saved to the same directory where you can download them for viewing in structure harvester or other like tools.


