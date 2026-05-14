#!/bin/bash
#
#SBATCH --cpus-per-task=40
#SBATCH --mem=100G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=01_align
#SBATCH --time=02:00:00
#SBATCH --account=rrg-surette


# Align the query sequences to the backbone fasta

while getopts "r:i:o:p:" arg
do
	case $arg in
		r)ref=$OPTARG;;
		o)outf=$OPTARG;;
		i)inf=$OPTARG;;
		p)threads=$OPTARG;;
	esac
done

if [[ -z $ref ]]
then
	echo "Must supply a reference ARB file with -r"
	exit 1
fi

if [[ -z $inf ]]
then
	echo "Must supply an input file with -i"
	exit 1
fi

if [[ -z $outf ]]
then
	echo "Must supply an output file with -o"
	exit 1
fi

if [[ -z $threads ]]
then
	echo "Number of threads (-p) not specified. Using 8."
	threads=8
fi

echo sina -r $ref -i $inf -o ${outf}  -p $threads\
	--fasta-write-dna -t --preserve-order\
	--outtype="fasta" --insertion="forbid" 
sina -r $ref -i $inf -o ${outf}  -p $threads\
	--fasta-write-dna -t --preserve-order\
	--outtype="fasta" --insertion="forbid" 
