#!/bin/bash

# do not touch these settings
#  number of tasks and nodes are fixed at 1
#$ -S /bin/sh
#$ -terse
#$ -V
#$ -cwd

# job name for pipeline
#  this name will appear when you monitor jobs with "squeue -u $USER"
#$ -N EFO27_H3k27ac

# walltime for your job
#  give long time enough to finish your pipeline
#  <12 hr: small/test samples
#  >24 hr: large samples
#$ -l h_rt=240:00:00
#$ -l s_rt=240:00:00

# total amount of memory
#  depends on the size of your FASTQs
#  but should be <= NUM_CONCURRENT_TASK x 20GB for big samples
#  or <= NUM_CONCURRENT_TASK x 10GB for small samples
#  do not request too much memory
#  cluster will not accept your job
#$ -l h_vmem=40G
#$ -l s_vmem=40G

# max number of cpus for each pipeline
#  should be <= NUM_CONCURRENT_TASK x "chip.bwa_cpu" in input JSON file
#  since bwa is a bottlenecking task in the pipeline
#  "chip.bwa_cpu" is a number of cpus per replicate
# SGE has a parallel environment (PE).
#  ask your admin to add a new PE named "smp"
#  or use your cluster's own PE instead of "smp"
#  2 means number of cpus per pipeline
#$ -pe smp 6

# load java module if it exists
module load java || true
module load singularity/2.5.2
module load cromwell/34
module load R
module load samtools

# use input JSON for a small test sample
#  you make an input JSON for your own sample
#  start from any of two templates for single-ended and paired-ended samples
#  (examples/template_se.json, examples/template_pe.json)
#  do not use an input JSON file for a test sample (ENCSR936XTK)
#  it's a sample with multimapping reads
INPUT=/common/genomics-core/data/Internal_Tests/CHIPseq_ATACseq_DI/ChIPseq/EFO27_A_H3k27ac_mem.json

# If this pipeline fails, then use this metadata JSON file to resume a failed pipeline from where it left 
# See details in /utils/resumer/README.md
PIPELINE_METADATA=EFO27_A_H3k27ac_metadata_mem.json

# limit number of concurrent tasks
#  we recommend to use a number of replicates here
#  so that all replicates are processed in parellel at the same time.
#  make sure that resource settings in your input JSON file
#  are consistent with SBATCH resource settings (--mem, --cpus-per-task) 
#  in this script
NUM_CONCURRENT_TASK=3

# run pipeline
#  you can monitor your jobs with "squeue -u $USER"
java -jar -Dconfig.file=/common/genomics-core/apps/chip-seq-pipeline2/backends/backend.conf -Dbackend.default=singularity \
-Dbackend.providers.singularity.config.concurrent-job-limit=${NUM_CONCURRENT_TASK} \
$CROMWELL run /common/genomics-core/apps/chip-seq-pipeline2/chip.wdl -i ${INPUT} -o /common/genomics-core/apps/chip-seq-pipeline2/workflow_opts/singularity.json -m ${PIPELINE_METADATA}

echo "Subject: ChIPseq is done" | sendmail -v di.wu@cshs.org
