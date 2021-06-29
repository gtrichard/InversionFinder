#!/bin/bash

echo "Step: show-coords"

show-coords -H -d -r -T $1 > $1_tmp1 

echo "Step: extract inversions and convert to bed"

grep "1	-1" $1_tmp1 | awk -v OFS="\t" '{print $10,$1,$2,$11,$3,$4}' | sort -k1,1 -k2,2n > $1_tmp2

echo "Step: chr name cleaning"

sed 's/C1/C01/g' $1_tmp2 | sed 's/C2/C02/g' | sed 's/C3/C03/g' | sed 's/C4/C04/g' | sed 's/C5/C05/g' | sed 's/C6/C06/g' |sed 's/C7/C07/g' |sed 's/C8/C08/g' | sed 's/C9/C09/g' | sed 's/B1/B01/g' | sed 's/B2/B02/g' | sed 's/B3/B03/g' | sed 's/B4/B04/g' | sed 's/B5/B05/g' | sed 's/B6/B06/g' | sed 's/B7/B07/g' | sed 's/B8/B08/g' | sed 's/CM007185.1/A01_CM007185.1/g' | sed 's/CM007186.1/A02_CM007186.1/g' | sed 's/CM007187.1/A03_CM007187.1/g' | sed 's/CM007188.1/A04_CM007188.1/g' | sed 's/CM007189.1/A05_CM007189.1/g' | sed 's/CM007190.1/A06_CM007190.1/g' | sed 's/CM007191.1/A07_CM007191.1/g' | sed 's/CM007192.1/A08_CM007192.1/g' | sed 's/CM007193.1/A09_CM007193.1/g' | sed 's/CM007194.1/A10_CM007194.1/g' | sed 's/CM007195.1/B07_CM007195.1/g' | sed 's/CM007196.1/B05_CM007196.1/g' | sed 's/CM007197.1/B08_CM007197.1/g' | sed 's/CM007198.1/B06_CM007198.1/g' | sed 's/CM007199.1/B01_CM007199.1/g' | sed 's/CM007200.1/B04_CM007200.1/g' | sed 's/CM007201.1/B03_CM007201.1/g' | sed 's/CM007202.1/B02_CM007202.1/g' > $1_tmp3

sleep 2

echo "#bed3" > $1_tmp4

sleep 2

echo "Step: extracting intra chromosomal inversions"

for pattern in A01 A02 A03 A04 A05 A06 A07 A08 A09 A10 B01 B02 B03 B04 B05 B06 B07 B08 C01 C02 C03 C04 C05 C06 C07 C08 C09;
do 
  grep $pattern.*$pattern $1_tmp3 >> $1_tmp4;
done

sleep 5

echo "Step: interative small inversions coordinates merging and size filtering"

tail -n +2 $1_tmp4 | awk -v OFS="\t" '{print $1,$2,$3,$3-$2}' | bedtools merge -d 200000 | bedtools merge -d 1000000 | awk -v OFS="\t" '{print $1,$2,$3,$3-$2}' | awk '$4 > 1000000 {print ;}' > $2

sleep 5

echo "Step: clean temporary files"

rm $1_tmp1
rm $1_tmp2
rm $1_tmp3
rm $1_tmp4

echo "Success"
