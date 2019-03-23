IMPORTANT:

1. That Singularity is now in a shared location (/hpc/apps/singularity/images). To use it, edit workflow_opts/singularity.json .

Change the line 

"singularity_container" : "~/.singularity/chip-seq-pipeline-v1.1.6.simg"

to

 "singularity_container" : "/hpc/apps/singularity/images/chip-seq-pipeline-v1.1.6.simg"
 
 2. If your users want to try the test samples suggested on the chip-seq-pipelin2 SGE tutorial page, they'll want to use either SGE singularity script, then make the following changes to the script.

1) Around line 7 or 8, add a "#$ -cwd" to deposit job output in the directory the job is submitted from
2) After the "module load java" line, add "module load singularity/2.5.2"
3) After "module load singularity/2.5.2", add the line "CROMWELL='/hpc/apps/cromwell/34/lib/cromwell.jar'"
4) Change the word "shm" to "smp" everywhere in the script
5) In the line at the end of the file, change "$HOME/cromwell-34.jar" to "$CROMWELL"

The file "test_genome_database/hg38_chr19_chrM_local.tsv refers to a non-existent file "test_genome_database/hg38_chr19_chrM/hg38.chrom.sizes". Either change the filename to "hg38_chr19_chrM.chrom.sizes", or copy test_genome_database/hg38_chr19_chrM/hg38_chr19_chrM.chrom.sizes to test_genome_database/hg38_chr19_chrM/hg38.chrom.sizes.

3. there are example JSON and batch files in example_HPC folder

4. for long paired-end reads, we should use "bwa mem" for the alignment. The command line is shown below:

/common/genomics-core/anaconda2/bin/bwa mem -M -t 10 /home/wangyiz/genomics/apps/chip-seq-pipeline2/genome/GRCh38/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta ./$1_R1.fastq.gz ./$1_R2.fastq.gz > $1.sam ###The reference genome should be the one used in the pipeline, be careful for the parameter setting.

samtools view -b -S $1.sam > $1.bam

samtools sort --output-fmt BAM -@ 10 -n -o $1.sorted.bam $1.bam  ### bam could be used as input for the pipeline




# ENCODE Transcription Factor and Histone ChIP-Seq processing pipeline

[![CircleCI](https://circleci.com/gh/ENCODE-DCC/chip-seq-pipeline2/tree/master.svg?style=svg)](https://circleci.com/gh/ENCODE-DCC/chip-seq-pipeline2/tree/master)

## Introduction 
This ChIP-Seq pipeline is based off the ENCODE (phase-3) transcription factor and histone ChIP-seq pipeline specifications (by Anshul Kundaje) in [this google doc](https://docs.google.com/document/d/1lG_Rd7fnYgRpSIqrIfuVlAz2dW1VaSQThzk836Db99c/edit#).

### Features

* **Flexibility**: Support for `docker`, `singularity` and `Conda`.
* **Portability**: Support for many cloud platforms (Google/DNAnexus) and cluster engines (SLURM/SGE/PBS).
* **Resumability**: [Resume](utils/qc_jsons_to_tsv/README.md) a failed workflow from where it left off.
* **User-friendly HTML report**: tabulated quality metrics including alignment/peak statistics and FRiP along with many useful plots (IDR/cross-correlation measures).
  - Examples: [HTML](https://storage.googleapis.com/encode-pipeline-test-samples/encode-chip-seq-pipeline/ENCSR000DYI/example_output/qc.html), [JSON](docs/example_output/v1.1.5/qc.json)
* **Genomes**: Pre-built database for GRCh38, hg19, mm10, mm9 and additional support for custom genomes.

## Installation and tutorial

This pipeline supports many cloud platforms and cluster engines. It also supports `docker`, `singularity` and `Conda` to resolve complicated software dependencies for the pipeline. A tutorial-based instruction for each platform will be helpful to understand how to run pipelines. There are special instructions for two major Stanford HPC servers (SCG4 and Sherlock).

* Cloud platforms
  * Web interface
    * [DNAnexus Platform](docs/tutorial_dx_web.md)
  * CLI (command line interface)
    * [Google Cloud Platform](docs/tutorial_google.md)
    * [DNAnexus Platform](docs/tutorial_dx_cli.md)
* Stanford HPC servers (CLI)
  * [Stanford SCG4](docs/tutorial_scg.md)
  * [Stanford Sherlock 2.0](docs/tutorial_sherlock.md)
* Cluster engines (CLI)
  * [SLURM](docs/tutorial_slurm.md)
  * [Sun GridEngine (SGE/PBS)](docs/tutorial_sge.md)
* Local computers (CLI)
  * [Local system with `singularity`](docs/tutorial_local_singularity.md)
  * [Local system with `docker`](docs/tutorial_local_docker.md)
  * [Local system with `Conda`](docs/tutorial_local_conda.md)

## Input JSON file

[Input JSON file specification](docs/input.md)

## Output directories

[Output directory specification](docs/output.md)

## Useful tools

There are some useful tools to post-process outputs of the pipeline.

### qc_jsons_to_tsv

[This tool](utils/qc_jsons_to_tsv/README.md) recursively finds and parses all `qc.json` (pipeline's [final output](docs/example_output/v1.1.5/qc.json)) found from a specified root directory. It generates a TSV file that has all quality metrics tabulated in rows for each experiment and replicate. This tool also estimates overall quality of a sample by [a criteria definition JSON file](utils/qc_jsons_to_tsv/criteria.default.json) which can be a good guideline for QC'ing experiments.

### resumer

[This tool](utils/resumer/README.md) parses a metadata JSON file from a previous failed workflow and generates a new input JSON file to start a pipeline from where it left off.

### ENCODE downloader

[This tool](https://github.com/kundajelab/ENCODE_downloader) downloads any type (FASTQ, BAM, PEAK, ...) of data from the ENCODE portal. It also generates a metadata JSON file per experiment which will be very useful to make an input JSON file for the pipeline.
