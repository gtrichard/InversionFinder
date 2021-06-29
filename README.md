# InversionsFinder
Snakemake-based pipeline to align multiple genomes and find large inversions.


## DESCRIPTION

InversionsFinder is a Snakemake pipeline using Mummer, Bedtools, Imagemagick and Gnuplot.

Given a list of genomes, it performs whole genome alignment using `nucmer` for each and every genome comparison in a two by two fashion. Alignments are then filtered using `delta-filter`, and further filtered during the plotting step of `mummerplot`. The resulting alignment plots are converted to pdf using Imagemagick `convert`. The alignment coordinates in both genomes are converted to a tab-delimited file using `show-coords` from Mummer, which is then parsed to keep only the small inverted synteny blocks aligning on the same chromosomes. The obtained small inverted synteny blocks coordinates are iteratively merged by `bedtools merge` and then size-selected to only keep large inversions (get_inversions_from_mummer.sh). The pipeline mainly executes the following shell commands:

```
nucmer {input.ref} {input.query} -p {params.prefix} -t {params.threads}
delta-filter -i 98 -l 10000 {input} > {output}
mummerplot -t postscript -s large -f -p {params.prefix} {input}
./get_inversions_from_mummer.sh {input} {output}
convert -density 400 {input} -resize 25% -rotate 90 {output}
```

`get_inversion_from_mummer.sh` mainly executes the following command after data cleaning:

```
bedtools merge -d 200000 | bedtools merge -d 700000 | awk -v OFS="\t" '{print $1,$2,$3,$3-$2}' | awk '$4 > 500000 {print ;}'
```

## INSTALLATION

Clone this repository and install the following conda environments that you activate and `--stack` before launching the pipeline.

```
gitclone https://github.com/gtrichard/InversionsFinder/
conda create -n bedtools -c bioconda bedtools
conda create -n mummer4 -c bioconda mummer4
conda create -n imagemagick -c conda-forge imagemagick
conda create -n gnuplot -c bioconda gnuplot
conda create -n snakemake -c bioconda snakemake
```


## USAGE

Activate and stack the different conda environments and launch the pipeline snakefile.

```
conda activate --stack bedtools 
conda activate --stack mummer4
conda activate --stack imagemagick 
conda activate --stack gnuplot 
conda activate --stack snakemake
snakemake -s InversionsFinder.snakefile -p --cluster 'sbatch --mincpus {params.threads} --mem-per-cpu {params.memory}' --jobs 10 -w 200 -k
```


## INPUT

As input, the pipeline uses a `fasta/` folder containing the genomes that will be aligned. The file names must end with the .chr.fasta suffix.
The name of the genomes must be changed in the header of the snakefile, excluding the .chr.fasta suffix.


## OUTPUT

In the `output/` folder, each genome comparison results are stored in a different folder. It notably contains the following files:

- `nucmer.delta`, storing the raw alignment data.
- `nucmer.delta.filtered.plot`, storing the filtered alignments used for plotting and inversions finding.
- `nucmer.delta.filtered.mummerplot.pdf`, alignments plot.
- `inversions_{genome1}_{genome2}.named.bed`,  inversions coordinates of the reference genome (first of the two genome names in the right columns).


## FOLDER STRUCTURE

The output folder stucture and logs are created automatically by the pipeline. Only the fasta folder is requied to be next to the InversionFinder.snakefile to launch the pipeline.

```
InversionFinder
|
|__InversionFinder.snakefile
|__get_inversions_from_mummer.sh
|
|__fasta/
|   |
|   |__genome1.chr.fasta
|   |__genome2.chr.fasta
|   |__genome3.chr.fasta
|   |__genome4.chr.fasta
|
|__output/
    |
    |__genome1.vs.genome1/
    |__genome1.vs.genome2/
    |__genome1.vs.genome3/
    |__genome1.vs.genome4/
    |__genome2.vs.genome1/
    |__genome2.vs.genome2/
    |__genome2.vs.genome3/
    |__genome2.vs.genome4/
    |__genome3.vs.genome1/
    |__genome3.vs.genome2/
    |__genome3.vs.genome3/
    |__genome3.vs.genome4/
    |__genome4.vs.genome1/
    |__genome4.vs.genome2/
    |__genome4.vs.genome3/
    |__genome4.vs.genome4/
```

## GENERALISATION

This pipeline has been designed to find inversions in 17 genomes of plants of the Brassica genus. Some values are hard-coded and thus need to be changed to be adapted to other genomes, namely:

1. Prefix of the fasta files that need to be processed line 1 of InversionsFinder.snakefile
2. The chromosome name cleaning line 13 of get_inversions_from_mummer.sh (if all your genomes have the same pattern, i.e. chr1, chr2, this doesn't need to be modified).
3. The chromosome names pattern to recognize to filter intra chromosomal inversions line 23 of get_inversions_from_mummer.sh.
