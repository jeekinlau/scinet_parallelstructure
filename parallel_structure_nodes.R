options(scipen=999)
library(ParallelStructure)
nodes = 4
runs = 10
k = 10  
nIter =100000
burnin =10000
datafile = "Structure_asteracea_33na_3_500dp.txt"
mrks = 5006
n_ind = 238
outpath_file = "/90daydata/byron_peach/rootstock/aster/structure/outputfiles/"

joblist = data.frame(run = paste0("run_", 1:(runs*k)),
                     pops = 1,
                     K = rep(1:k,runs),
                     burnin = burnin,
                     nIter=nIter)

write.table(joblist,file="joblist.txt",row.names = F, col.names = F, quote = F)

#read in joblist
joblist = read.table("joblist.txt",header=F)

#split joblist into nodes equal chunks
chunk_size = ceiling(nrow(joblist)/nodes)
for (i in 1:nodes){
  chunk = joblist[((i-1)*chunk_size+1):(i*chunk_size),]
  write.table(chunk,file=paste0("joblist_",i,".txt"),row.names = F, col.names = F, quote = F)
}


# look for number of files in directory matching "joblist_"
job_files = list.files(pattern = "joblist_")


# write R script to run parallel structure code
for ( i in 1:length(job_files)){
  file = data.frame(code=c("library(ParallelStructure)",
                           "temp_dir=system(command='readlink -f $TMPDIR',  intern=T)",
                           "setwd(temp_dir)",
                           paste0("parallel_structure(structure_path='/software/el9/apps/structure/2.3.4/',infile='",datafile,"',joblist = 'joblist_",i,".txt',outpath='",outpath_file,"', markernames = 1,numinds=",n_ind,",numloci=",mrks,",ploidy=2,n_cpu=",chunk_size,",printqhat=1)")))
  
  write.table(file, file=paste0("code_",i,".R"), row.names = F, col.names = F, quote = F)
}

# create a sbatch file for every node
for (i in 1:length(job_files)){
  slurm_file = data.frame(code=c("#!/bin/bash",
                                 paste0("#SBATCH --job-name=structure_node",i),
                                 "#SBATCH --nodes=1",
                                 "#SBATCH --ntasks-per-node=72",
                                 "#SBATCH --mem=350G",
                                 "#SBATCH --time=5-00:00:00",
                                 "#SBATCH --partition=medium", 
                                 "#SBATCH --mail-user=jeekin.lau@usda.gov",
                                 paste0("cp /90daydata/byron_peach/rootstock/aster/structure/",datafile," $TMPDIR"),
                                 paste0("cp /90daydata/byron_peach/rootstock/aster/structure/joblist_",i,".txt"," $TMPDIR"),  
                                 "ml structure/2.3.4 r/4.3.1",
                                 paste0("Rscript code_",i,".R")))
  write.table(slurm_file, file=paste0("slurm_node_",i,".SLURM"), row.names = F, col.names = F, quote = F)
  system(command = paste0("sbatch ","slurm_node_",i,".SLURM"))
}
