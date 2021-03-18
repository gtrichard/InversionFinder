genomes='bjuncea_T84-66 bjuncea_varuna bnapus_darmor10 bnapus_ganganF73 bnapus_no2127 bnapus_quintaA bnapus_rccs0 bnapus_shengli3 bnapus_tapidor3 bnapus_westar bnapus_zheyou73 bnapus_zs11 bnigra_c2 bnigra_ni100 boleracea_hdem boleracea_d134 brapa_chiifu3 brapa_z1'

rule all:
    input:
        expand("output/{genome1}.vs.{genome2}/nucmer.delta", genome1=genomes.split(' '), genome2=genomes.split(' ')),
        expand("output/{genome1}.vs.{genome2}/nucmer.delta.filtered.plot", genome1=genomes.split(' '), genome2=genomes.split(' ')),
        expand("output/{genome1}.vs.{genome2}/nucmer.delta.filtered.mummerplot.filter", genome1=genomes.split(' '), genome2=genomes.split(' ')),
	expand("output/{genome1}.vs.{genome2}/nucmer.delta.filtered.mummerplot.ps", genome1=genomes.split(' '), genome2=genomes.split(' ')),
        expand("output/{genome1}.vs.{genome2}/inversions_{genome1}_{genome2}.named.bed", genome1=genomes.split(' '), genome2=genomes.split(' ')),
	expand("output/{genome1}.vs.{genome2}/nucmer.delta.filtered.mummerplot.pdf", genome1=genomes.split(' '), genome2=genomes.split(' '))

rule nucmer:
    input:
        ref='fasta/{genome1}.chr.fasta',
        query='fasta/{genome2}.chr.fasta'
    output:
        delta="output/{genome1}.vs.{genome2}/nucmer.delta"
    params:
        threads=32,
        memory='1G',
        prefix='output/{genome1}.vs.{genome2}/nucmer'
    log:
        err="logs/nucmer/{genome1}.vs.{genome2}.log",
        out="snakemakelogs/nucmer/nucmer/{genome1}.vs.{genome2}.log"
    shell:
        'nucmer {input.ref} {input.query} -p {params.prefix} -t {params.threads} 2> {log.err}'

rule filter_plot:
    input:
        "output/{genome1}.vs.{genome2}/nucmer.delta"
    output:
        "output/{genome1}.vs.{genome2}/nucmer.delta.filtered.plot"
    params:
        threads=4,
        memory='1G'
    log:
        err="logs/filter_plot/{genome1}.vs.{genome2}.log",
        out="snakemakelogs/filter_plot/{genome1}.vs.{genome2}.log"
    shell:
        "delta-filter -i 98 -l 10000 {input} > {output} 2> {log.err}"

rule mummerplot:
    input:
        "output/{genome1}.vs.{genome2}/nucmer.delta.filtered.plot"
    output:
        filter="output/{genome1}.vs.{genome2}/nucmer.delta.filtered.mummerplot.filter",
	plot="output/{genome1}.vs.{genome2}/nucmer.delta.filtered.mummerplot.ps"
    params:
        threads=8,
        memory="500M",
        prefix="output/{genome1}.vs.{genome2}/nucmer.delta.filtered.mummerplot"
    log:
        err="logs/mummerplot/{genome1}.vs.{genome2}.log",
        out="snakemakelogs/mummerplot/{genome1}.vs.{genome2}.log"
    shell:
        "mummerplot -t postscript -s large -f -p {params.prefix} {input} 2> {log.err}"

rule get_inversions:
    input:
         "output/{genome1}.vs.{genome2}/nucmer.delta.filtered.mummerplot.filter"
    output:
         "output/{genome1}.vs.{genome2}/inversions_{genome1}_{genome2}.bed"
    params:
        threads=4,
        memory='1G'
    log:
        err="logs/inversions/{genome1}.vs.{genome2}.log",
        out="snakemakelogs/inversions/{genome1}.vs.{genome2}.log"
    shell:
        "./get_inversions_from_mummer.sh {input} {output} 2> {log.err}"

rule get_inversions_named:
    input:
        "output/{genome1}.vs.{genome2}/inversions_{genome1}_{genome2}.bed"
    output:
        "output/{genome1}.vs.{genome2}/inversions_{genome1}_{genome2}.named.bed"
    params:
        threads=4,
        memory='1G'
    log:
        err="logs/inversions_named/{genome1}.vs.{genome2}.log",
        out="snakemakelogs/inversions_named/{genome1}.vs.{genome2}.log"
    shell:
         """awk -v OFS="\t" -v var1="{wildcards.genome1}" -v var2="{wildcards.genome2}" "{{print \$1,\$2,\$3,var1,var2}}" {input} > {output} 2> {log.err}"""


rule imagemagick:
    input:
        "output/{genome1}.vs.{genome2}/nucmer.delta.filtered.mummerplot.ps"
    output:
        "output/{genome1}.vs.{genome2}/nucmer.delta.filtered.mummerplot.pdf"
    params:
        threads=8,
        memory="500M"
    log:
        err="logs/imagemagick/{genome1}.vs.{genome2}.log",
        out="snakemakelogs/mummerplot/{genome1}.vs.{genome2}.log"
    shell:
        "convert -density 400 {input} -resize 25% -rotate 90 {output}"
