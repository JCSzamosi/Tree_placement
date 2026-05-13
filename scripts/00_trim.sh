#!/bin/bash
#

# Trim the first base off each sequence in a fasta file

while getopts "i:o:" arg
do
	case $arg in
		i)inf=$OPTARG;;
		o)outf=$OPTARG;;
	esac
done

if [[ -z $inf ]]
then
	echo "Must supply an input fasta with -i"
	exit 1
fi

if [[ -z $outf ]]
then
	echo "Must supply an output file with -o"
	exit 1
fi

echo "awk '/^>/ { print } !/^>/ { print substr($0, 2) }' $inf > $outf"
awk '/^>/ { print } !/^>/ { print substr($0, 2) }' $inf > $outf


