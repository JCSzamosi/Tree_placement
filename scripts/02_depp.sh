#!/bin/bash
#
#SBATCH --cpus-per-task=40
#SBATCH --mem=100G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=03_depp
#SBATCH --time=02:00:00
#SBATCH --account=rrg-surette


while getopts "r:q:m:o:c:" arg
do
	case $arg in
		r)ref=$OPTARG;;
		q)query=$OPTARG;;
		m)model=$OPTARG;;
		o)outf=$OPTARG;;
		c)cont=$OPTARG;;
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

if [[ -z $query ]]
then
	echo "Must supply a query file with -q"
	exit 1
fi

if [[ -z $model ]]
then
	echo "Must supply a trained model file with -m"
	exit 1
fi

if [[ -z $cont ]]
then
	echo "Must supply a container file with -c"
	exit 1
fi


echo module load apptainer
module load apptainer

echo apptainer run $cont ./scripts/run_depp.sh -r $ref -q $query -m $model
apptainer run $cont ./scripts/run_depp.sh -r $ref -q $query -m $model

echo mv depp_distance/depp.csv $outf
mv depp_distance/depp.csv $outf
echo rm -r depp_distance
rm -r depp_distance
