#!/bin/bash
#

while getopts "r:q:m:" args
do
	case $args in
		r)ref=$OPTARG;;
		q)query=$OPTARG;;
		m)model=$OPTARG;;
	esac
done

echo depp_distance.py backbone_seq_file=$ref query_seq_file=$query model_path=$model
depp_distance.py backbone_seq_file=$ref query_seq_file=$query model_path=$model
