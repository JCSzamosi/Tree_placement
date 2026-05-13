#!/bin/bash
#
#SBATCH --cpus-per-task=40
#SBATCH --mem=100G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=00_convert_reference
#SBATCH --time=02:00:00
#SBATCH --account=rrg-surette


# Convert the backbone fasta alignment to arb format

while getopts "r:o:p:" arg
do
	case $arg in
		r)ref=$OPTARG;;
		o)outf=$OPTARG;;
		p)threads=$OPTARG;;
	esac
done

if [[ -z $ref ]]
then
	echo "Must supply a reference fasta with -r"
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

echo sina -i $ref --prealigned -o $outf --outtype="ARB" -p $threads
sina -i $ref --prealigned -o $outf --outtype="ARB" -p $threads
