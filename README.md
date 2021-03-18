# InversionFinder
Snakemake-based pipeline to align multiple genomes and find large inversions.


## DESCRIPTION

InversionFinder is a Snakemake pipeline using Mummer, Bedtools, Imagemagick and Gnuplot.

Given a list of genomes, it performs whole genome alignment using `nucmer` for each and every genome comparison in a two by two fashion. Alignments are then filtered using `delta-filter`, and further filtered during the plotting step of `mummerplot`. The resulting alignment plots are converted to pdf using Imagemagick `convert`. The alignment coordinates in both genomes are converted to a tab-delimited file using `show-coords` from Mummer, which is then parsed to keep only the small inverted synteny blocks aligning on the same chromosomes. The obtained small inverted synteny blocks coordinates are iteratively merged by `bedtools merge` and then size-selected to only keep large inversions (get_inversions_from_mummer.sh).


## INSTALLATION

Clone this repository and install the following conda environments that you activate and `--stack` before launching the pipeline.

```
gitclone https://github.com/gtrichard/InversionFinder/
conda create -n bedtools -c bioconda bedtools
conda create -n mummer4 -c bioconda mummer
conda create -n imagemagick -c bioconda imagemagick
conda create -n gnuplot -c bioconda gnuplot
conda create -n snakemake -c bioconda snakemake
```


## USAGE

Activate and stack the different conda environments and launch the pipeline snakefile.

```
conda activate --stack bedtools 
conda activate --stack mummer 
conda activate --stack imagemagick 
conda activate --stack gnuplot 
conda activate --stack snakemake
snakemake -s InversionFinder.snakefile -p --cluster 'sbatch --mincpus {params.threads} --mem-per-cpu {params.memory}' --jobs 10 -w 200 -k
```

