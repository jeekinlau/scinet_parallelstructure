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


## Stucture file input format
The input file for parallelstructure is a bit finicky and has to be very specific.
![screenshot of input](/screenshots/Screenshot%202024-09-16%20134240.png)

The first column is the individual ID (two rows per individual). The second column is the population ID (just put all as one pop if you do not know). The remainin columns are markers information. 1/1 is homozygous for ref allele, 1/2 is heterozygous, and 2/2 is homozygous for alt allele.


## General outline of scripts

Two main scripts. One slurm job script and one R script.
The slurm job script is used to submit a master R script to the cluster and this R Script will create the other R scripts and other slurm job scripts to parallelize parallelstructure on multiple nodes. The outputs should all be saved to the same directory where you can download them for viewing in structure harvester or other like tools.

### SLURM job file
All the slurm job does is create run the main R script. you could also just run the R script directly on the login node as there is little to no computation. All it does is creating the other slurm job files and the other R scripts that are actuall running on the compute nodes.

```
#!/bin/bash
#SBATCH --job-name=makejobs       # Job name
#SBATCH --nodes=1                     # Number of nodes
#SBATCH --ntasks-per-node=1           # Number of tasks per node
#SBATCH --mem=1G
#SBATCH --time=1:00:00                # Maximum runtime (D-HH:MM:SS)
#SBATCH --mail-type=ALL               # Send email at job completion
#SBATCH --mail-user=jeekin.lau@usda.gov    # Email address for notifications
ml structure/2.3.4 r/4.3.1
Rscript parallel_structure_nodes.R
```


### R script 
The R script has the meat of what you need. At the top of the script you will find the parameters you need to set.

```
nodes = 4   # sets the number of compute nodes to run on 
runs = 10 # sets number of runs per K
k = 10  # this will run from 1 to k 
nIter =100000 # number of iterations to run
burnin =10000  # number of burnin iterations
datafile = "Structure_asteracea_33na_3_500dp.txt" # input file
mrks = 5006 # number of markers
n_ind = 238   # number of individuals
outpath_file = "/90daydata/byron_peach/rootstock/aster/structure/outputfiles/" # output file path for all the analysis to collate into
```

### description of the R script
A quick explanation of what the R script is doing.

1. it is creating a joblist that will have all the runs that you want to feed into ParallelStructure.
2. Then it is splitting the joblist into equal chunks for each node.
3. Then it is writing the R script to run the ParallelStructure code on each node.
4. Then it is writing the sbatch file to run the R script on each node. 


As a technical note, the R script you will NEED to change the path of line 56 and line 57 to the location of your your datafile.
What these lines are doing is copying the datafile to the temporary directory on the compute node. These are SSD drives connected to the compute node and is much faster data access as parallelstructure makes a duplicate of the data for each instance it is running. If this is done on /90daydata/ then hours will be spent just copying the data from the original file to a temporary file the ParallelStructure will use for each instance in analysis. also the I/O is faster on SSD drives so presumably should speed up analysis.

I should not have hardcoded these paths but havent made another variable up at top to make this portion of the script dynamic. I know this works as is.

Please feel free to adapt and use code in any way you see fit.
