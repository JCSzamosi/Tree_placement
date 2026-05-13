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

while getopts "t:o:i:" arg
do
	case $arg in
		t)tre=$OPTARG;;
		o)outf=$OPTARG;;
		i)idf=$OPTARG;;
	esac
done

if [[ -z $tre ]]
then
	echo "Must supply a tree file with -t"
	exit 1
fi

if [[ -z $outf ]]
then
	echo "Must supply an output file name with -o"
	exit 1
fi

if [[ -z $idf ]]
then
	echo "Must supply a file of node IDs with -i"
	exit 1
fi

echo "nw_prune -v -f <(nw_topology -bI $tre) $idf > $outf"
nw_prune -v -f <(nw_topology -bI $tre) $idf > $outf
