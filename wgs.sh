#!/bin/bash


# MESSAGE IMPORTANT : Je dois vous avertir que beaucoup de ces lignes m'ont été transmise par Maël Pretet. Il ne serait pas honnête de ma part de recevoir des points bonus à la note finale grâce à ce travail.


# Load needed modules
module purge
module load bowtie2
module load samtools

# Going to the directory where the job has been submitted from
cd /shared/projects/uparis_m2_bi_2020/metagenomique_2


#BOWTIE2

srun -c 12 bowtie2 -p 12 -x databases/all_genome.fasta -1 fastq/EchG_R1.fastq.gz -2 fastq/EchG_R2.fastq.gz -S mkermarrec/results_bowtie_echG.sam

#SAMTOOLS

srun -c 12 samtools view -@ 12 -bS mkermarrec/results_bowtie_echG.sam > mkermarrec/results_bowtie_echG.bam 

srun -c 12 samtools sort -@ 12 mkermarrec/results_bowtie_echG.bam  > mkermarrec/results_bowtie_echG_sort.bam

srun -c 12 samtools index -@ 12 mkermarrec/results_bowtie_echG_sort.bam

srun -c 12 samtools idxstats -@ 12 mkermarrec/results_bowtie_echG_sort.bam > mkermarrec/results_bowtie_echG_stat

#GREP

grep ">" databases/all_genome.fasta|cut -f 2 -d ">" >mkermarrec/association.tsv

#MEGAHIT

srun -c 12 --mem 8G megahit -1 fastq/EchG_R1.fastq.gz  -2 fastq/EchG_R2.fastq.gz  -t 12  -o mkermarrec/megahit_result --k-list 21

srun -c 12 prodigal -d mkermarrec/EchG_R1_prodigal.fasta -i mkermarrec/megahit_result/final.contigs.fa -o mkermarrec/prodigal_results.gbk

sed "s:>:*\n>:g" mkermarrec/EchG_R1_prodigal.fasta | sed -n "/partial=00/,/*/p"|grep -v "*" > mkermarrec/genes_full.fna

srun -c 12 blastn -perc_identity 80 -qcov_hsp_perc 80 -db databases/resfinder.fna -query mkermarrec/genes_full.fna -out mkermarrec/blastn.out -num_threads 12 -evalue 0.003

