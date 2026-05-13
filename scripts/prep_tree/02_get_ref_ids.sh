#!/bin/bash
#
#SBATCH --cpus-per-task=40
#SBATCH --mem=100G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=01_align
#SBATCH --time=02:00:00
#SBATCH --account=rrg-surette


# Convert the backbone fasta alignment to arb format

trim=no

while getopts "r:o:t" arg
do
	case $arg in
		r)ref=$OPTARG;;
		o)outf=$OPTARG;;
		t)trim=yes;;
	esac
done

if [[ -z $ref ]]
then
	echo "Must supply a reference fasta with -r"
	exit 1
fi

if [[ -z $outf ]]
then
	echo "Must supply an output file name with -o"
	exit 1
fi

if [[ $trim = "yes" ]]
then
	grep ">" $ref | sed "s/^>//g" | sed "s/_[0-9]*$//" | sort | uniq > $outf
else
	echo "-t not specified. Not trimming '_N'."
	grep ">" $ref | sed "s/^>//g" | sort > $outf
fi

