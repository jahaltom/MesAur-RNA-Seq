#!/bin/bash

#SBATCH --time=1:00:00
#SBATCH -p RM-shared
#SBATCH --ntasks-per-node=30

source activate pyrpipe_covid


mkdir MesAur_data
cd MesAur_data


#cdna.all' - all transcripts of Ensembl genes, excluding ncRNA.
wget http://ftp.ensembl.org/pub/release-107/fasta/mesocricetus_auratus/cdna/Mesocricetus_auratus.MesAur1.0.cdna.all.fa.gz

#These files hold the transcript sequences corresponding to non-coding RNA genes (ncRNA)
wget http://ftp.ensembl.org/pub/release-107/fasta/mesocricetus_auratus/ncrna/Mesocricetus_auratus.MesAur1.0.ncrna.fa.gz


#Get Mesocricetus auratus Genome
wget http://ftp.ensembl.org/pub/release-107/fasta/mesocricetus_auratus/dna/Mesocricetus_auratus.MesAur1.0.dna.toplevel.fa.gz

#download covid seq
wget -q ftp://ftp.ensemblgenomes.org/pub/viruses/fasta/sars_cov_2/cdna/Sars_cov_2.ASM985889v3.cdna.all.fa.gz


gunzip *gz

#Replace space with |. Remove gene:
sed -i 's/ /|/g' Mesocricetus_auratus.MesAur1.0.cdna.all.fa 
sed -i 's/gene://g' Mesocricetus_auratus.MesAur1.0.cdna.all.fa
sed -i 's/ /|/g' Mesocricetus_auratus.MesAur1.0.ncrna.fa 
sed -i 's/gene://g' Mesocricetus_auratus.MesAur1.0.ncrna.fa




#create decoy list with genome.
grep ">" Mesocricetus_auratus.MesAur1.0.dna.toplevel.fa | cut -d " " -f 1 | tr -d ">" > decoys.txt

#combine transcriptomes and decoy fasta files.
cat Mesocricetus_auratus.MesAur1.0.cdna.all.fa Mesocricetus_auratus.MesAur1.0.ncrna.fa Sars_cov_2.ASM985889v3.cdna.all.fa Mesocricetus_auratus.MesAur1.0.dna.toplevel.fa > MesAur_sars_tx_decoy.fasta


#cleanup
rm Mesocricetus_auratus.MesAur1.0.cdna.all.fa Mesocricetus_auratus.MesAur1.0.ncrna.fa Sars_cov_2.ASM985889v3.cdna.all.fa Mesocricetus_auratus.MesAur1.0.dna.toplevel.fa

#create salmon index
time salmon index -t MesAur_sars_tx_decoy.fasta -d decoys.txt -p 30 -i salmon_index
