#!/bin/bash
# takes 4th column of bedGraph and normalized values so they fall into 0-1 range
# then converts the normalized bedGraph file to bigWig file

echo -e What is the full path to the file with chromosome sizes?
read chromSize

for i in *.bedGraph
do 

	# get the file name without suffix
	cell="${i%_blRemoved.*}"
	echo $cell
	
	# define file names - add suffix _normalized to both bedGraph and bigWig
	bgFile=$cell"_normalized.bedGraph"
	bwFile=$cell"_normalized.bw"

	# normalize data - datailed explanation in "Cell_specificity_in_elements" notes
	echo "normalizing track 0-1"
	awk 'NR==1 { max=$4 ; min=$4 }
     FNR==NR { if ($4>=max) max=$4 ; $4<=min?min=$4:0 ; next}
     { $4=($4-min)/(max-min) ; print }' $i $i > $bgFile

	#convert bedGraph to bigWig
	echo "convert to bigWig"
	bedGraphToBigWig $bgFile $chromSize $bwFile
	
	# remove the unnormalized file
	rm $i
done
