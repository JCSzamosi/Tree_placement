#!/bin/bash
#

while getopts "e:t:o:@:d:q:r:" arg
do
	case $arg in
		e)venv=$OPTARG;;
		t)tree=$OPTARG;;
		@)threads=$OPTARG;;
		d)dist=$OPTARG;;
		q)query=$OPTARG;;
		r)resd=$OPTARG;;
		p)pref=$OPTARG;;
	esac
done

if [[ -z $venv ]]
then
	echo "Python virtual environment not specified with -e. Using `lib/apples_env`"
	venv=lib/apples_env
fi

if [[ -z $tree ]]
then
	echo "Reference tree file must be specified with -t"
	exit 1
fi

if [[ -z $threads ]]
then
	echo "Number of threads not specified. Using 8."
	threads=8
fi

if [[ -z $dist ]]
then
	echo "Distance file must be specified with -d"
	exit 1
fi

if [[ -z $query ]]
then
	echo "Query fasta file must be specified with -q"
	exit 1
fi

if [[ -z $pref ]]
then
	echo "Output file prefix must be specified with -p."
	exit 1
fi

if [[ -z $resd ]]
then
	echo "A results folder has not been specified. Using `results/`"
	resd=results/
fi

module load python/3.14.2 gappa/0.9.0

echo mkdir -p $resd
mkdir -p $resd

# Load the virtual env

jplace=${resd}/${pref}.jplace

echo source $venv/bin/activate
source $venv/bin/activate

echo run_apples.py -t $tree -o $jplace -T $threads -d $dist
run_apples.py -t $tree -o $jplace -T $threads -d $dist

echo gappa examine graft --jplace-path $resd --out-dir $resd
gappa examine graft --jplace-path $resd --out-dir $resd

qids=${resd}/${pref}_ids.txt
echo ./scripts/prep_tree/02_get_ref_ids.sh -r $query -o $qids
./scripts/prep_tree/02_get_ref_ids.sh -r $query -o $qids

outf=${resd}/${pref}_pruned_tree.nwk

echo nw_prune -v -f $tree $qids > $outf
nw_prune -v -f $tree $qids > $outf
