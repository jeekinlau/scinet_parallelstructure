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
