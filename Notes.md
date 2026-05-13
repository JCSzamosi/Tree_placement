Placing 16S Sequences on a Tree
===============================

This pipeline uses SINA, newick_utils, depp, and apples to place new sequences on
an existing bacterial tree for which a 16S alignment already exists. There are
two steps: 1) prepping the tree and its sequences, and 2) aligning our sequences
and placing them on the tree.

This pipeline is intended to be run on Digital Research Alliance Canada's
servers, so software installation assumes that's where you are. Writing scripts
to set up all the software is a stretch goal of this repository. For now I'm
working on the pipeline to run the software.

Required software is

* [SINA](https://sina.readthedocs.io/en/latest/)
* [newick_utils](https://github.com/tjunier/newick_utils)
* [DEPP](https://github.com/yueyujiang/DEPP)
* [apples](https://github.com/navidh86/apples)
* [gappa](https://github.com/lczech/gappa)
* [mothur](https://mothur.org/)

as well as basic unix utils like `sed`, `awk`, and `grep`.

`SINA` and newick_utils are standalone programs that are not present on Nibi. I
have downloaded their source files, run the config and `make` steps, and added
them to my `$PATH`. This might not be the best way but it is what I am doing.

`DEPP` works best if you run it inside the provided container. Because we can't
use Docker images on DRAC computers, I have converted the Docker image to an
Apptainer file following [these
instructions](https://docs.alliancecan.ca/wiki/Apptainer#Creating_an_Apptainer_container_from_a_Dockerfile).
The apptainer file is not tracked under git.

`apples` is a python module that is not kept in the Nibi available wheels, so it
has to be installed without the `--no-index` flag. I create a virtual
environment following [these
instructions](https://docs.alliancecan.ca/wiki/Python#Pre-downloading_packages).

`gappa` is actually available on Nibi, so I load it using `module load
gappa/0.9.0`

## Prep Tree

This only needs to be done once per tree per 16S region, so if you use the same
tree each time, and always sequence the same 16S region, you only need to do it
once.

You need a tree file (`$tre`) and a curated alignment provided by whoever
created the tree (aka "backbone alignment"), in fasta or arb format, that is
trimmed to exactly your 16S region. To use v3-v4 sequences amplified by the
Surette lab, you can either use the Web of Life tree and its pre-trimmed v3-v4
alignment provided by the DEPP team, or you can use the LTP tree and trim its
16S alignment down using our sequencing primers.

If the backbone alignment is in fasta format you need to convert it to arb using
`SINA`:

```
./scripts/prep_tree/01_convert_backbone.sh \
    -r ref_seqs.fna \
    -o ref_seqs.arb \
    -p n_threads
```

Next, you need to get the IDs from the backbone fasta file, and make sure they
match the format of the IDs in the newick tree file, so that they can be used to
prune the reference tree. Exactly how you do this will depend on which tree
you're using, but the provided script will do it if you're using the Web of Life
files:

```
./scripts/prep_tree/02_get_ref_ids_wol.txt \
    -r ref_seqs.fna \
    -o ref_ids.txt \
    -t
```

If the IDs in the reference fasta already match what's present in the tree, you
can just leave off the final `-t` and it will work.

Finally, you need to prune the reference tree to just the sequences present in
your reference fasta. Depending on how the tree was built, not all regions are
necessarily present in all leaves, so this removes any leaves for which the ID
is missing from the reference fasta file.

```
./scripts/prep_tree/03_prune_reference.sh \
    -t ref_tree.nwk \
    -o pruned_tree.nwk \
    -i ref_ids.txt
```



## Place Your Data

Once your tree is prepped, you need your own 16S ASVs or OTUs in a fasta file.

The first step is to align your query sequences to the reference backbone
alignment.

If you are using v3-v4 amplified by the Surette lab, and the WoL v3v4 file
provided by the DEPP team, you will need to trim the first base off each of your
query sequences so that the region exactly lines up with the reference region.
This base is always a C, so you're not losing any information here.

```
./scripts/00_trim.sh \
    -i query_seqs.fna \
    -o query_seqs_trimmed.fna
```

We use `SINA` to do a reference-based alignment of our query sequences with the
reference arb alignment.

```
./scripts/01_align.sh \
    -r ref_seqs.arb \
    -i query_seqs.fna \
    -o query_alignment.fna \
    -p nthreads
```

Once the alignment exists, we use `DEPP` to generate a distance matrix using
both the query and reference alignments. If you're using the WoL files from the
DEPP team, use their pre-trained model here. Otherwise, use the model you
trained during the prep steps.

```
./scripts/02_depp.sh \
    -r ref_seqs.fna \
    -q query_alignment.fna \
    -m model_file.pth \
    -o dist_file.csv
```

This script will temporarily create a directory called depp_distance and, inside
it, a file called depp.csv. It will clobber any such file that already exists,
and delete that directory whether it already existed or not, so make sure
there's nothing there you care about.

Now that we have the distance file, we use `apples` to place our query sequences
on the reference tree, then `gappa` to graft them onto the tree, and finally
`newick_utils` to prune the tree down to just our sequences. This requires you
to have a python virtual environment with `apples` installed.

```
./script/03_place.sh \
    -e apples_env \
    -t ref_tree.nwk \
    -@ nthreads \
    -d dist_file.csv \
    -q query_seqs.fna \
    -r results/ \
    -p output_prefix
```
